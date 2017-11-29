/********************************************************************************
 * Copyright (c) 2011-2017 Red Hat Inc. and/or its affiliates and others
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Apache License, Version 2.0 which is available at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * SPDX-License-Identifier: Apache-2.0 
 ********************************************************************************/
import org.eclipse.ceylon.model.loader.mirror {
    TypeParameterMirror,
    TypeMirror
}
import org.eclipse.ceylon.model.typechecker.model {
    TypeParameter
}

import java.util {
    Collections
}

shared class JTypeParameterMirror(TypeParameter param) satisfies TypeParameterMirror {
    
    bounds => Collections.emptyList<TypeMirror>();
    
    name => param.nameAsString;
    
}