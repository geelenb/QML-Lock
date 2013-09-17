/*
Copyright 2013 Bram Geelen

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   */

import QtQuick 2.0
import Ubuntu.Components 0.1
import "colors.js" as Colors

MainView {
    id: window
    //    height: 240
    height: 400
    //    height: 900
    width: 400

    Rectangle {
        id: main
        height: Math.min(parent.height, parent.width)
        width: height
        anchors.centerIn: parent
        radius: height / 2
        color: Colors.mainCircle

        signal correct
        onCorrect: {
            console.log("Correct!")
            center.locked = false
            currentCode = []
        }

        property var code: [-1, 1, 2, 3, 4, -1]
        property var currentCode: []
        property int maxnum: 12
        property bool numbersVisible: false

        function addNumber (number) {
            if (repeater.itemAt(0).bigR >= main.height / 3)  {
                currentCode.push(number)
                console.log(currentCode)
                if (number !== -1)
                    repeater.itemAt(number).dot.color = Colors.pointsSelected
            }
        }

        function checkCorrect() {
            if (currentCode.length !== code.length)
                return false;
            for (var i = 0; i < code.length; i++)
                if (currentCode[i] !== code[i])
                    return false;

            correct();
            for (i = 0; i < code.length; i++) {
                if(code[i] !== -1) {
                    repeater.itemAt(code[i]).border.color = Colors.pointsBorderCorrect
                    repeater.itemAt(code[i]).dot.color = Colors.pointsCorrect
                }
            }

            center.color = Colors.centerCorrect
            return true;
        }

        function reset() {
            if (!checkCorrect()) {
                currentCode = []
                for (var i = 0; i < repeater.count; i++) {
                    repeater.itemAt(i).border.color = Colors.pointsBorder
                    repeater.itemAt(i).dot.color = Colors.points
                }
                center.color = Colors.center
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onReleased: main.reset()

            onPositionChanged: {
                if (pressed)
                    reEvaluate()
            }

            function reEvaluate() {
                var child = main.childAt(mouseX, mouseY)
                if (child !== null && child.number !== undefined) {
                    var number = main.childAt(mouseX, mouseY).number
                    if (main.currentCode.length === 0 || main.currentCode[main.currentCode.length - 1] !== number) {
                        main.addNumber(number)
                    }
                }
            }
        }

        Rectangle {
            id: center
            height: main.height / 3
            width: height
            radius: height / 2
            property int radiusSquared: radius * radius
            anchors.centerIn: parent
            color: Colors.center
            property int number: -1

            property bool locked: true

            Image {
                visible: center.locked
                source: Qt.resolvedUrl("locked.png")
                anchors.fill: parent
                anchors.margins: parent.height / 5
                fillMode: Image.PreserveAspectFit
            }

            Image {
                visible: !center.locked
                source: Qt.resolvedUrl("unlocked.png")
                anchors.fill: parent
                anchors.margins: parent.height / 5
                fillMode: Image.PreserveAspectFit
            }
        }

        Repeater {
           id: repeater
           model: main.maxnum

           Rectangle {
               id: selectionRect
               height: bigR * Math.abs(Math.sin(180.0 / main.maxnum))//main.height / 10
               width: height
               radius: height / 2
               color: Colors.pointsBackground
               border.color: Colors.pointsBorder
               border.width: 0
               property int number: index
               property alias dot: centerDot

               property int bigR: mouseArea.pressed ?  main.height / 2.7 : 0
               property int offsetRadius: radius
               x: (main.width / 2) + bigR * Math.sin(2 * Math.PI * index / main.maxnum) - offsetRadius
               y: (main.height / 2) - bigR * Math.cos(2 * Math.PI * index / main.maxnum) - offsetRadius

               Rectangle {
                   id: centerDot
                   height: parent.height / 8
                   width: height
                   radius: height / 2
                   anchors.centerIn: parent
                   color: Colors.points
               }

               Behavior on bigR {
                   UbuntuNumberAnimation {}
               }
           }
        }

        Repeater {
           id: numbers
           model: main.maxnum

           Text {
               font.pixelSize: main.height / 12
               width: height
               color: Colors.numbers
               text: index
               visible: main.numbersVisible

               property int bigR: main.height / 3.5
               property int offsetRadius: height / 2
               x: (main.width / 2) + bigR * Math.sin(2 * Math.PI * index / main.maxnum) - height /4
               y: (main.height / 2) - bigR * Math.cos(2 * Math.PI * index / main.maxnum) - offsetRadius
           }
        }
    }
}
