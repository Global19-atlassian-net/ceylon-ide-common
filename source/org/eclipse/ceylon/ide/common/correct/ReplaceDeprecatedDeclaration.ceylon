/********************************************************************************
 * Copyright (c) 2011-2017 Red Hat Inc. and/or its affiliates and others
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Apache License, Version 2.0 which is available at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * SPDX-License-Identifier: Apache-2.0 
 ********************************************************************************/
import org.eclipse.ceylon.compiler.typechecker.analyzer {
    UsageWarning,
    Warning
}
import org.eclipse.ceylon.ide.common.platform {
    platformServices,
    ReplaceEdit
}
import org.eclipse.ceylon.ide.common.util {
    nodes
}
import org.eclipse.ceylon.model.typechecker.model {
    Function,
    Declaration
}
import org.eclipse.ceylon.compiler.typechecker.tree {
    Tree
}
import ceylon.collection {
    HashSet
}

"Replaces usages of deprecated declarations with known alternatives.
 For example:
 
     hello(javaClass<Foo>())
 
 becomes:
 
     hello(Types.classForType<Foo>)
 "
shared object replaceDeprecatedDeclaration {
    
    value replacements = map {
        "ceylon.interop.java::javaClass" -> "Types.classForType",
        "ceylon.interop.java::javaClassFromInstance" -> "Types.classForInstance",
        "ceylon.interop.java::javaClassFromDeclaration" -> "Types.classForDeclaration",
        "ceylon.interop.java::javaClassFromModel" -> "Types.classForModel",
        "ceylon.interop.java::javaString" -> "Types.nativeString",
        "ceylon.interop.java::javaStackTrace" -> "Types.stackTrace"
    };
    
    shared void addProposal(QuickFixData data, UsageWarning warning) {
        if (warning.warningName == Warning.deprecation.name()) {
            replaceJavaClass(data, warning);
        }
    }
    
    void replaceJavaClass(QuickFixData data, UsageWarning warning) {
        if (is Tree.Identifier id = nodes.getIdentifyingNode(data.node),
            is Function decl = nodes.getReferencedModel(data.node),
            exists newText = replacements.get(decl.qualifiedNameString)) {

            value oldText = nodes.text(data.tokens, id);

            value change = platformServices.document.createTextChange {
                name = "Replace Deprecated Function";
                input = data.phasedUnit;
            };

            value unit = data.rootNode.unit;
            if (exists typesDec
                    = unit.javaLangPackage
                    ?.getMember("Types", null, false)) {
                value decs = HashSet<Declaration>();
                importProposals.importDeclaration {
                    declarations = decs;
                    declaration = typesDec;
                    rootNode = data.rootNode;
                    scope = id.scope;
                };
                importProposals.applyImports {
                    change = change;
                    declarations = decs;
                    rootNode = data.rootNode;
                    scope = id.scope;
                    doc = data.document;
                };
            }

            change.addEdit(ReplaceEdit {
                start = id.startIndex.intValue();
                length = id.distance.intValue();
                text = newText;
            });
            data.addQuickFix("Replace '``oldText``()' with '``newText``()'", change);
        }
    }
}
