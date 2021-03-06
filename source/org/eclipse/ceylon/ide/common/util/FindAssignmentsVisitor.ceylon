/********************************************************************************
 * Copyright (c) 2011-2017 Red Hat Inc. and/or its affiliates and others
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Apache License, Version 2.0 which is available at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * SPDX-License-Identifier: Apache-2.0 
 ********************************************************************************/
import ceylon.collection {
    HashSet
}
import ceylon.interop.java {
    JavaSet
}

import org.eclipse.ceylon.compiler.typechecker.tree {
    Visitor,
    Node,
    Tree
}
import org.eclipse.ceylon.model.typechecker.model {
    Declaration,
    Parameter,
    FunctionOrValue,
    Value,
    Setter
}

import java.util {
    JSet=Set
}
import java.lang {
    overloaded
}

shared class FindAssignmentsVisitor extends Visitor {
    
    shared Declaration declaration;
    value nodes = HashSet<Node>();
    
    shared new (Declaration declaration) extends Visitor() {
        if (is Value declaration) {
            variable value result = declaration;
            while (is Value original = result.originalDeclaration, 
                original!=result && original!=declaration) {
                result = original;
            }
            if (exists param = result.initializerParameter,
                is Setter setter = param.declaration) {
                this.declaration = setter.getter else setter;
            }
            else {
                this.declaration = result;
            }
        }
        else {
            this.declaration = declaration;
        }
    }
    
    shared Set<Node> assignmentNodes => nodes;
    shared JSet<Node> assignmentNodeSet => JavaSet(nodes);
    
    Boolean isParameterReference(Parameter? p) 
            => if (exists p) then isReference(p.model) else false;
    
    Boolean isReference(Declaration? ref) {
        if (exists ref, declaration.refines(ref)) {
            return true;
        }
        else if (is FunctionOrValue ref, 
                ref.shortcutRefinement && 
                ref.refinedDeclaration==declaration) {
            return true;
        }
        else {
            return false;
        }
    }
    
    Boolean isTermReference(Tree.Term lhs) 
            => if (is Tree.MemberOrTypeExpression lhs) 
            then isReference(lhs.declaration) else false;

    overloaded
    shared actual void visit(Tree.TypeParameterDeclaration that) {
        super.visit(that);
        if (that.typeSpecifier exists) {
            if (isReference(that.declarationModel)) {
                nodes.add(that.typeSpecifier);
            }
        }
    }

    overloaded
    shared actual void visit(Tree.TypeAliasDeclaration that) {
        super.visit(that);
        if (that.typeSpecifier exists) {
            if (isReference(that.declarationModel)) {
                nodes.add(that.typeSpecifier);
            }
        }
    }

    overloaded
    shared actual void visit(Tree.ClassDeclaration that) {
        super.visit(that);
        if (that.classSpecifier exists) {
            if (isReference(that.declarationModel)) {
                nodes.add(that.classSpecifier);
            }
        }
    }

    overloaded
    shared actual void visit(Tree.InterfaceDeclaration that) {
        super.visit(that);
        if (that.typeSpecifier exists) {
            if (isReference(that.declarationModel)) {
                nodes.add(that.typeSpecifier);
            }
        }
    }

    overloaded
    shared actual void visit(Tree.SpecifierStatement that) {
        super.visit(that);
        variable value lhs = that.baseMemberExpression;
        while (is Tree.ParameterizedExpression pe=lhs) {
            lhs = pe.primary;
        }
        
        if (isTermReference(lhs)) {
            nodes.add(that.specifierExpression);
        }
    }

    overloaded
    shared actual void visit(Tree.InitializerParameter that) {
        super.visit(that);
        if (that.specifierExpression exists) {
            if (isParameterReference(that.parameterModel)) {
                nodes.add(that.specifierExpression);
            }
        }
    }

    overloaded
    shared actual void visit(Tree.AssignmentOp that) {
        super.visit(that);
        value lhs = that.leftTerm;
        if (isTermReference(lhs)) {
            nodes.add(that.rightTerm);
        }
    }

    overloaded
    shared actual void visit(Tree.PostfixOperatorExpression that) {
        super.visit(that);
        value lhs = that.term;
        if (isTermReference(lhs)) {
            nodes.add(that.term);
        }
    }

    overloaded
    shared actual void visit(Tree.PrefixOperatorExpression that) {
        super.visit(that);
        value lhs = that.term;
        if (isTermReference(lhs)) {
            nodes.add(that.term);
        }
    }

    overloaded
    shared actual void visit(Tree.AttributeDeclaration that) {
        super.visit(that);
        if (exists sie = that.specifierOrInitializerExpression, 
            isReference(that.declarationModel)) {
            nodes.add(sie);
        }
    }

    overloaded
    shared actual void visit(Tree.MethodDeclaration that) {
        super.visit(that);
        if (exists se = that.specifierExpression, 
            isReference(that.declarationModel)) {
            nodes.add(se);
        }
    }

    overloaded
    shared actual void visit(Tree.Variable that) {
        super.visit(that);
        if (exists se = that.specifierExpression, 
            isReference(that.declarationModel)) {
            nodes.add(se);
        }
    }

    overloaded
    shared actual void visit(Tree.NamedArgument that) {
        if (isParameterReference(that.parameter)) {
            if (is Tree.SpecifiedArgument that) {
                value sa = that;
                nodes.add(sa.specifierExpression);
            } else {
                nodes.add(that);
            }
        }
        
        super.visit(that);
    }

    overloaded
    shared actual void visit(Tree.PositionalArgument that) {
        if (isParameterReference(that.parameter)) {
            nodes.add(that);
        }
        
        super.visit(that);
    }

    overloaded
    shared actual void visit(Tree.SequencedArgument that) {
        if (isParameterReference(that.parameter)) {
            nodes.add(that);
        }
        
        super.visit(that);
    }

    overloaded
    shared actual void visit(Tree.StaticMemberOrTypeExpression that) {
        value typeArguments = that.typeArguments;
        if (is Tree.TypeArgumentList typeArguments, 
            exists dec = that.declaration) {
            value typeParameters = dec.typeParameters;
            value types = typeArguments.types;
            variable value i = 0;
            while (i < types.size() && i < typeParameters.size()) {
                if (isReference(typeParameters.get(i))) {
                    nodes.add(types.get(i));
                }
                i++;
            }
        }
        
        super.visit(that);
    }

    overloaded
    shared actual void visit(Tree.SimpleType that) {
        if (exists typeArguments = that.typeArgumentList,
            exists value dec = that.declarationModel) {
            value typeParameters = dec.typeParameters;
            value types = typeArguments.types;
            variable Integer i = 0;
            while (i < types.size() && i < typeParameters.size()) {
                if (isReference(typeParameters.get(i))) {
                    nodes.add(types.get(i));
                }
                i++;
            }
        }
        
        super.visit(that);
    }

    overloaded
    shared actual void visit(Tree.Return that) {
        if (isReference(that.declaration)) {
            nodes.add(that);
        }
        
        super.visit(that);
    }
}