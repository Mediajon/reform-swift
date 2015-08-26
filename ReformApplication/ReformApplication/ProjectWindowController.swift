//
//  ProjectWindowController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformCore
import ReformExpression
import ReformStage
import ReformMath
import ReformTools

class ProjectWindowController : NSWindowController {


    lazy var picture : ReformCore.Picture = ReformCore.Picture(identifier : PictureIdentifier(0), name: "Untiled", size: (580,330), data: self.data, procedure: self.procedure)

    lazy var project : Project = Project(pictures: self.picture)
    


    lazy var projectSession : ProjectSession = ProjectSession(project: self.project)


    lazy var pictureSession : PictureSession = PictureSession(projectSession: self.projectSession, picture: self.picture)

    var procedure = Procedure()
    let data = BaseSheet()


    override func windowDidLoad() {
        if let screenFrame = window?.screen?.frame {
            window?.setFrame(NSRect(x:25, y:100, width: screenFrame.width-50, height: screenFrame.height-120), display: true)
            window?.center()
        }

        let rectangleForm = RectangleForm(id: FormIdentifier(98), name: "Rectangle 1")

        let lineForm = LineForm(id: FormIdentifier(99), name: "Line 1")

        let rectangleDestination = RelativeDestination(
            from: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.TopLeft.rawValue),
            to: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.Center.rawValue)
        )

        let lineDestination = RelativeDestination(
            from: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.TopLeft.rawValue),
            to: ForeignFormPoint(formId: rectangleForm.identifier, pointId: RectangleForm.PointId.BottomLeft.rawValue)
        )

        let createInstruction = CreateFormInstruction(form: rectangleForm, destination: rectangleDestination)

        let node1 = InstructionNode(instruction: createInstruction)

        procedure.root.append(child: node1)

        let moveInstruction = TranslateInstruction(formId: rectangleForm.identifier, distance: RelativeDistance(
            from: ForeignFormPoint(formId: rectangleForm.identifier, pointId: RectangleForm.PointId.Center.rawValue),
            to: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.Center.rawValue),
            direction: FreeDirection()))

        let node2 = InstructionNode(instruction: moveInstruction)

        procedure.root.append(child: node2)

        let rotateInstruction = RotateInstruction(
            formId: rectangleForm.identifier,
            angle: ConstantAngle(angle: Angle(percent: 20)),
            fixPoint: ForeignFormPoint(formId: procedure.paper.identifier, pointId: Paper.PointId.Center.rawValue)
        )

        let node3 = InstructionNode(instruction: rotateInstruction)

        procedure.root.append(child: node3)

        let createLineInstruction = CreateFormInstruction(form: lineForm, destination: lineDestination)
        let node4 = InstructionNode(instruction: createLineInstruction)

        procedure.root.append(child: node4)

        pictureSession.instructionFocus.current = node4

        if let pictureController = contentViewController as? PictureController {

            pictureController.representedObject = pictureSession
        }

        pictureSession.refresh()
    }
    

    @IBAction func selectToolCreateLine(sender: AnyObject) {
        pictureSession.tool = pictureSession.createLineTool
    }

    @IBAction func selectToolCreateRectangle(sender: AnyObject) {
        pictureSession.tool = pictureSession.createRectTool
    }

    @IBAction func selectToolCreateCircle(sender: AnyObject) {
        pictureSession.tool = pictureSession.createCircleTool
    }

    @IBAction func selectToolCreatePie(sender: AnyObject) {
        pictureSession.tool = pictureSession.createPieTool

    }

    @IBAction func selectToolCreateArc(sender: AnyObject) {
        pictureSession.tool = pictureSession.createArcTool

    }

    @IBAction func selectToolMove(sender: AnyObject) {
        pictureSession.tool = pictureSession.moveTool
    }


    @IBAction func selectToolMorph(sender: AnyObject) {
        pictureSession.tool = pictureSession.morphTool

    }


    @IBAction func selectToolRotate(sender: AnyObject) {
        pictureSession.tool = pictureSession.rotationTool

    }


    @IBAction func selectToolScale(sender: AnyObject) {
        pictureSession.tool = pictureSession.scalingTool

    }

    override func validateToolbarItem(theItem: NSToolbarItem) -> Bool {

        if let _ = ToolbarIdentifier(rawValue: theItem.itemIdentifier) {
            return true
        } else {
            return false
        }
    }

    @IBAction func toolbarButton(sender: NSToolbarItem) {
    }

    enum ToolbarIdentifier : String {
        case LineToolItem
        case RectangleToolItem
        case CircleToolItem
        case PieToolItem
        case ArcToolItem

        case MoveToolItem
        case RotateToolItem
        case ScaleToolItem
        case MorphToolItem
    }
    
}