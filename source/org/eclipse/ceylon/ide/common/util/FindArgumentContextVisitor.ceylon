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
import java.lang {
    overloaded
}

class FindArgumentContextVisitor(Node term) extends Visitor() {
    
    shared variable [Tree.InvocationExpression?, Tree.SequencedArgument?, Tree.NamedArgument|Tree.PositionalArgument?]? context = null;
    
    variable Tree.NamedArgument|Tree.PositionalArgument? currentArgument = null;
    variable Tree.SequencedArgument? currentSequencedArgument = null;
    variable Tree.InvocationExpression? currentInvocation = null;
    
    alias InvocationArgument => Tree.NamedArgument|Tree.PositionalArgument;

    overloaded
    shared actual void visit(Tree.NamedArgument that) {
        InvocationArgument? myOuter = currentArgument;
        currentArgument = that;
        super.visit(that);
        currentArgument = myOuter;
    }

    overloaded
    shared actual void visit(Tree.PositionalArgument that) {
        InvocationArgument? myOuter = currentArgument;
        currentArgument = that;
        super.visit(that);
        currentArgument = myOuter;
    }

    overloaded
    shared actual void visit(Tree.SequencedArgument that) {
        currentSequencedArgument = that;
        super.visit(that);
        currentSequencedArgument = null;
    }

    overloaded
    shared actual void visit(Tree.InvocationExpression that) {
        Tree.InvocationExpression? myOuter = currentInvocation;
        Tree.SequencedArgument? myOuterSequencedArgument = currentSequencedArgument;
        currentInvocation = that;
        super.visit(that);
        currentInvocation = myOuter;
        currentSequencedArgument = myOuterSequencedArgument;
    }
    
    shared actual void visitAny(Node node) {
        if (node == term) {
            context = [currentInvocation, currentSequencedArgument, currentArgument];
        }
        
        if (!exists c = context) {
            super.visitAny(node);
        }
    }
}
