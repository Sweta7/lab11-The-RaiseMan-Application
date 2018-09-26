//
//  Document.swift
//  RaiseMan
//
//  Created by Sweta on 25/09/18.
//  Copyright © 2018 Sweta. All rights reserved.
//

import Cocoa

class Document: NSDocument {
    @objc dynamic private static var myContext = 0
    @objc dynamic var employees = NSMutableArray() {
        willSet {
            for person in employees {
                stopObservingPerson(person as! Person)
            }
        }
        didSet {
            for person in employees {
                startObservingPerson(person as! Person)
            }
        }
    }
    
    
    override init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        self.addWindowController(windowController)
        
        let ourViewController = windowController.contentViewController
        ourViewController?.representedObject = self
    }

    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }
    
    @objc func insertObject(_ p:Person, inEmployeesAtIndex index:Int){
        NSLog("adding %@ to %@",p,employees)
        // add the inverse of the insertion action to the undo stack
        if let undo = self.undoManager {
            (undo.prepare(withInvocationTarget: self) as AnyObject).removeObjectFromEmployeesAtIndex(index)
            if !undo.isUndoing {
                undo.setActionName("Add Person")
            }
            // Add the person to the NSMutableArray
            employees.insert(p, at: index)
        }
    }
    @objc func removeObjectFromEmployeesAtIndex(_ index:Int){
        let p = employees.object(at: index) as! Person
        NSLog("removing %@ from %@",p,employees)
        // add the inverse of the insertion action to the undo stack
        if let undo = self.undoManager {
            (undo.prepare(withInvocationTarget: self) as AnyObject).insertObject(p, inEmployeesAtIndex: index)
            if !undo.isUndoing {
                undo.setActionName("Remove Person")
            }
            // Remove the person from the NSMutableArray
            employees.removeObject(at: index)
        }
    }
    
    func startObservingPerson(_ person:Person){
        person.addObserver(self, forKeyPath: "personName", options: NSKeyValueObservingOptions.old, context: &Document.myContext)
        person.addObserver(self, forKeyPath: "expectedRaise", options: NSKeyValueObservingOptions.old, context: &Document.myContext)
    }
    func stopObservingPerson(_ person:Person){
        person.removeObserver(self, forKeyPath: "personName", context: &Document.myContext)
        person.removeObserver(self, forKeyPath: "expectedRaise", context: &Document.myContext)
    }
    
    @objc func changeKeyPath(keyPath:String, ofObject obj:NSObject, toValue newValue:AnyObject){
        obj.setValue(newValue, forKey: keyPath)
    }
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context != &Document.myContext {
            // message must have been intended for our superclass
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if let o = object as? NSObject {
            if let undo = self.undoManager {
                let oldValue:AnyObject = change![NSKeyValueChangeKey.oldKey]! as AnyObject
                NSLog("oldValue = \(oldValue)")
                (undo.prepare(withInvocationTarget: self) as AnyObject).changeKeyPath(keyPath: keyPath!, ofObject: o, toValue: oldValue)
                undo.setActionName("Edit")
            }
        }
    }

}

