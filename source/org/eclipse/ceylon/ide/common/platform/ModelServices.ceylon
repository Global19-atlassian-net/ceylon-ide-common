/********************************************************************************
 * Copyright (c) 2011-2017 Red Hat Inc. and/or its affiliates and others
 *
 * This program and the accompanying materials are made available under the 
 * terms of the Apache License, Version 2.0 which is available at
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * SPDX-License-Identifier: Apache-2.0 
 ********************************************************************************/
import org.eclipse.ceylon.ide.common.model {
    ModelAliases,
    ProjectSourceFile,
    EditedSourceFile,
    CrossProjectSourceFile
}
import org.eclipse.ceylon.ide.common.typechecker {
    TypecheckerAliases,
    CrossProjectPhasedUnit,
    EditedPhasedUnit,
    ProjectPhasedUnit
}
import org.eclipse.ceylon.ide.common.model.parsing {
    RootFolderScanner
}

shared interface ModelServices<NativeProject, NativeResource, NativeFolder, NativeFile>
        satisfies ModelAliases<NativeProject, NativeResource, NativeFolder, NativeFile>
        & TypecheckerAliases<NativeProject, NativeResource, NativeFolder, NativeFile>
        given NativeProject satisfies Object
        given NativeResource satisfies Object
        given NativeFolder satisfies NativeResource
        given NativeFile satisfies NativeResource {

    shared formal Boolean nativeProjectIsAccessible(NativeProject nativeProject);

    "Existing source folders as read from the IDE native project"
    shared formal {NativeFolder*} sourceNativeFolders(CeylonProjectAlias ceylonProject);
    "Existing resource folders as read from the IDE native project"
    shared formal {NativeFolder*} resourceNativeFolders(CeylonProjectAlias ceylonProject);
    
    shared formal {NativeProject*} referencedNativeProjects(NativeProject nativeProject);

    shared formal {NativeProject*} referencingNativeProjects(NativeProject nativeProject);
    

    shared formal void scanRootFolder(RootFolderScanner<NativeProject, NativeResource, NativeFolder, NativeFile> scanner);
    
    
    "Instanciate a [[ProjectSourceFile]] object from a [[ProjectPhasedUnit]] 
     with the concrete type parameters corresponding to the current IDE platform
    
     Necessary because of [issue #25](https://github.com/ceylon/ceylon-ide-common/issues/25)"
    shared formal ProjectSourceFileAlias newProjectSourceFile(ProjectPhasedUnitAlias phasedUnit);
    
    "Instanciate a [[CrossProjectSourceFile]] object from a [[CrossProjectPhasedUnit]] 
     with the concrete type parameters corresponding to the current IDE platform
    
     Necessary because of [issue #25](https://github.com/ceylon/ceylon-ide-common/issues/25)"
    shared formal CrossProjectSourceFileAlias newCrossProjectSourceFile(CrossProjectPhasedUnitAlias phasedUnit);
    
    "Instanciate a [[EditedSourceFile]] object from an [[EditedPhasedUnit]] 
     with the concrete type parameters corresponding to the current IDE platform
     
     Necessary because of [issue #25](https://github.com/ceylon/ceylon-ide-common/issues/25)"
    shared formal EditedSourceFileAlias newEditedSourceFile(EditedPhasedUnitAlias phasedUnit);
    
    shared formal Boolean isResourceContainedInProject(NativeResource resource, CeylonProjectAlias ceylonProject);
}