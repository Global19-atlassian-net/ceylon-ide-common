import ceylon.collection {
    ArrayList
}
import ceylon.test {
    test,
    assertFalse,
    assertTrue
}

import org.eclipse.ceylon.ide.common.configuration {
    CeylonRepositoryConfigurator
}

import java.lang {
    JString=String,
    ObjectArray,
    IntArray
}


object dummyConfigurator extends CeylonRepositoryConfigurator() {
    
    shared ArrayList<String> myRepos = ArrayList<String>(10, 1.5, {"my global repo", "other remote repo"});

    shared actual variable IntArray selection = IntArray(1);
    shared variable Boolean isDownEnabled = false;
    shared variable Boolean isUpEnabled = false;
    shared variable Boolean isRemoveEnabled = false;
    
    shared actual void addAllRepositoriesToList(ObjectArray<JString> repos) {
        for (JString? repo in repos.iterable) {
            if (exists repo) {
                myRepos.add(repo.string);
            }
        }
    }
    
    shared actual void addRepositoryToList(Integer index, String repo) {
        selection[0] = index;
        myRepos.insert(index, repo);
    }
    
    
    shared actual String removeRepositoryFromList(Integer index) {
        return myRepos.delete(index) else "";
    }
    
    shared actual void enableDownButton(Boolean enabled) => isDownEnabled = enabled;
    
    shared actual void enableRemoveButton(Boolean enabled) => isRemoveEnabled = enabled;
    
    shared actual void enableUpButton(Boolean enabled) => isUpEnabled = enabled;
}

test shared void testRepositoryConfiguration() {
    dummyConfigurator.addGlobalLookupRepo("my global repo");
    dummyConfigurator.addOtherRemoteRepo("other remote repo");
    
    dummyConfigurator.updateButtonState();
    assertFalse(dummyConfigurator.isDownEnabled);
    assertFalse(dummyConfigurator.isUpEnabled);
    assertFalse(dummyConfigurator.isRemoveEnabled);

    // Selecting a pre-configured repo does not enable buttons
    dummyConfigurator.selection[0] = 0;
    dummyConfigurator.updateButtonState();
    assertFalse(dummyConfigurator.isDownEnabled);
    assertFalse(dummyConfigurator.isUpEnabled);
    assertFalse(dummyConfigurator.isRemoveEnabled);
    
    // Adding a maven repo will put it just before "other remote repo"
    dummyConfigurator.addAetherRepo("maven");
    assertFalse(dummyConfigurator.isDownEnabled);
    assertTrue(dummyConfigurator.isUpEnabled);
    assertTrue(dummyConfigurator.isRemoveEnabled);
    
    // Adding an external repo will put it on top
    dummyConfigurator.addExternalRepo("external");
    assertTrue(dummyConfigurator.isDownEnabled);
    assertFalse(dummyConfigurator.isUpEnabled);
    assertTrue(dummyConfigurator.isRemoveEnabled);
    
    // Moving the first repo down will enable the up button
    dummyConfigurator.moveSelectedReposDown();
    assertTrue(dummyConfigurator.isDownEnabled);
    assertTrue(dummyConfigurator.isUpEnabled);
    assertTrue(dummyConfigurator.isRemoveEnabled);

    // Moving this repo down again put it just before "other remote repo"
    dummyConfigurator.moveSelectedReposDown();
    assertFalse(dummyConfigurator.isDownEnabled);
    assertTrue(dummyConfigurator.isUpEnabled);
    assertTrue(dummyConfigurator.isRemoveEnabled);
    
    // The last repo can't be moved/removed
    dummyConfigurator.selection[0] = dummyConfigurator.myRepos.size - 1;
    dummyConfigurator.updateButtonState();
    assertFalse(dummyConfigurator.isDownEnabled);
    assertFalse(dummyConfigurator.isUpEnabled);
    assertFalse(dummyConfigurator.isRemoveEnabled);
}