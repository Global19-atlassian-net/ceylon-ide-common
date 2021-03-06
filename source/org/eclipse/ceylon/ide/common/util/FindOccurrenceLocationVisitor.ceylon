/********************************************************************************
 * Copyright (c) 2011-2017 Red Hat Inc. and/or its affiliates and others
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Apache License, Version 2.0 which is available at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * SPDX-License-Identifier: Apache-2.0 
 ********************************************************************************/
import org.eclipse.ceylon.compiler.typechecker.tree {
    Visitor,
    Node,
    Tree
}
import org.eclipse.ceylon.ide.common.util {
    OccurrenceLocation {
        ...
    }
}
import java.lang {
    overloaded
}

class FindOccurrenceLocationVisitor(Integer offset, Node node) 
        extends Visitor() {
    
    shared variable OccurrenceLocation? occurrence = null;
    variable Boolean inTypeConstraint = false;

    overloaded
    actual shared void visitAny(Node that) {
        if (inBounds(that))  {
            super.visitAny(that);
        }
        //otherwise, as a performance optimization
        //don't go any further down this branch
    }

    overloaded
    actual shared void visit(Tree.Condition that) {
        if (inBounds(that)) {
            occurrence = \iEXPRESSION;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.ExistsCondition that) {
        super.visit(that);
        if (exists var = that.variable) {
            value isInBounds 
                    = if (is Tree.Variable var) 
                    then inBounds(var.identifier) 
                    else inBounds(that);
            if (isInBounds) {
                occurrence = \iEXISTS;
            }
        }
    }

    overloaded
    actual shared void visit(Tree.ConditionList that) {
        if (inBounds(that)) {
            value conditions = that.conditions;
            if (!conditions.empty) {
                value size = conditions.size();
                for (i in 1..size) {
                    value current = conditions.get(i-1);
                    value next = i<size then conditions.get(i);
                    if (current.endToken == current.token,
                        current.endIndex.intValue()<offset,
                        if (exists next) 
                        then next.startIndex.intValue()>offset 
                        else true) {
                        switch (current)
                        case (is Tree.ExistsCondition) {
                            occurrence = \iEXISTS;
                        }
                        case (is Tree.NonemptyCondition) {
                            occurrence = \iNONEMPTY;
                        }
                        case (is Tree.IsCondition) {
                            occurrence = \iIS;
                        }
                        else {
                            continue;
                        }
                        return;
                    }
                }
            }
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.NonemptyCondition that) {
        super.visit(that);
        if (exists var = that.variable) {
            value isInBounds 
                    = if (is Tree.Variable var) 
                    then inBounds(var.identifier) 
                    else inBounds(that);
            if (isInBounds) {
                occurrence = \iNONEMPTY;
            }
        }
    }

    overloaded
    actual shared void visit(Tree.IsCondition that) {
        super.visit(that);
        Boolean isInBounds;
        if (exists var = that.variable) {
            isInBounds = inBounds(var.identifier);
        }
        else if (exists type = that.type) {
            isInBounds = inBounds(that) 
                    && offset>type.endIndex.intValue();
        }
        else {
            isInBounds = false;
        }
        if (isInBounds) {
            occurrence = \iIS;
        }
    }

    overloaded
    actual shared void visit(Tree.TypeConstraint that) {
        inTypeConstraint=true;
        super.visit(that);
        inTypeConstraint=false;
    }

    overloaded
    actual shared void visit(Tree.ImportMemberOrTypeList that) {
        if (inBounds(that)) {
            occurrence = \iIMPORT;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.ExtendedType that) {
        if (inBounds(that)) {
            occurrence = \iEXTENDS;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.DelegatedConstructor that) {
        if (inBounds(that)) {
            occurrence = \iEXTENDS;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.SatisfiedTypes that) {
        if (inBounds(that)) {
            occurrence = if (inTypeConstraint) 
                then \iUPPER_BOUND 
                else \iSATISFIES;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.CaseTypes that) {
        if (inBounds(that)) {
            occurrence = \iOF;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.CatchClause that) {
        if (inBounds(that) && 
            !inBounds(that.block)) {
            occurrence = \iCATCH;
        }
        else {
            super.visit(that);
        }
    }

    overloaded
    actual shared void visit(Tree.CaseItem that) {
        if (inBounds(that),
            !that.mainEndToken exists ||
            offset<that.endIndex.intValue()) {
            occurrence = \iCASE;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.BinaryOperatorExpression that) {
        Tree.Term right = that.rightTerm else that;
        Tree.Term left = that.leftTerm else that;
        
        if (inBounds(left, right)) {
            occurrence = \iEXPRESSION;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.UnaryOperatorExpression that) {
        Tree.Term term = that.term else that;

        if (inBounds(that, term) || inBounds(term, that)) {
            occurrence = \iEXPRESSION;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.ParameterList that) {
        if (inBounds(that)) {
            occurrence = \iPARAMETER_LIST;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.TypeParameterList that) {
        if (inBounds(that)) {
            occurrence = \iTYPE_PARAMETER_LIST;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.TypeSpecifier that) {
        if (inBounds(that)) {
            occurrence = \iTYPE_ALIAS;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.ClassSpecifier that) {
        if (inBounds(that)) {
            occurrence = \iCLASS_ALIAS;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.SpecifierOrInitializerExpression that) {
        if (inBounds(that)) {
            occurrence = \iEXPRESSION;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.ArgumentList that) {
        if (inBounds(that)) {
            occurrence = \iEXPRESSION;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.TypeArgumentList that) {
        if (inBounds(that)) {
            occurrence = \iTYPE_ARGUMENT_LIST;
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.QualifiedMemberOrTypeExpression that) {
        if (inBounds(that.memberOperator, that.identifier)) {
            occurrence = \iEXPRESSION;
        }
        else {
            super.visit(that);
        }
    }

    overloaded
    actual shared void visit(Tree.Declaration that) {
        if (inBounds(that)) {
            if (exists o = occurrence, o != \iPARAMETER_LIST) {
                occurrence=null;
            }
        }
        super.visit(that);
    }

    overloaded
    actual shared void visit(Tree.MetaLiteral that) {
        super.visit(that);
        if (inBounds(that)) {
            if (exists o = occurrence, o != \iTYPE_ARGUMENT_LIST) {
                occurrence = switch (that.nodeType)
                    case ("ModuleLiteral") \iMODULE_REF 
                    case ("PackageLiteral") \iPACKAGE_REF 
                    case ("ValueLiteral") \iVALUE_REF 
                    case ("FunctionLiteral") \iFUNCTION_REF 
                    case ("InterfaceLiteral") \iINTERFACE_REF 
                    case ("ClassLiteral") \iCLASS_REF 
                    case ("TypeParameterLiteral") \iTYPE_PARAMETER_REF 
                    case ("AliasLiteral") \iALIAS_REF
                    else \iMETA;
            }
        }
    }

    overloaded
    actual shared void visit(Tree.StringLiteral that) {
        if (inBounds(that)) {
            occurrence = \iDOCLINK;
        }
    }

    overloaded
    actual shared void visit(Tree.DocLink that) {
        if (is Tree.DocLink node) {
            occurrence = \iDOCLINK;
        }
    }
    
    Boolean inBounds(Node? left, Node? right = left) {
        if (exists startIndex = left?.startIndex,
            exists stopIndex = right?.endIndex,
            exists nodeStartIndex = node.startIndex,
            exists nodeEndIndex = node.endIndex) {
            return startIndex.intValue() <= nodeStartIndex.intValue()
                && stopIndex.intValue() >= nodeEndIndex.intValue();
        }
        else {
            return false;
        }
    }
}