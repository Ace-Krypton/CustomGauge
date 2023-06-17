import QtQuick
import QtQuick3D
import QtQuick3D.Particles3D

Item {
  id: mainGauge
  width: view3D.implicitWidth
  height: view3D.implicitHeight

  property real separation: 0
  readonly property real meterTicksAngle: 300
  readonly property bool particleNeedle: false

  anchors.fill: parent

  Behavior on separation {
    SmoothedAnimation {
      velocity: 0.2
      duration: 1000
    }
  }

  View3D {
    id: view3D
    anchors.fill: parent
    focus: true

    environment: SceneEnvironment {
      clearColor: "#161610"
      backgroundMode: SceneEnvironment.Color
      antialiasingMode: SceneEnvironment.MSAA
      antialiasingQuality: SceneEnvironment.VeryHigh
    }

    PerspectiveCamera {
      position: Qt.vector3d(0, 100, 600 - separation * 100)
    }

    PointLight {
      position: Qt.vector3d(1200, 400, 300)
      brightness: 5
      ambientColor: Qt.rgba(0.3, 0.3, 0.3, 1.0)
    }

    Model {
      source: "#Rectangle"
      scale: Qt.vector3d(25, 15, 0)
      z: -300

      materials: PrincipledMaterial {
        baseColor: "#505040"
      }
    }

    Node {
      id: speedometerComponent

      position: Qt.vector3d(0, 100, 0)
      eulerRotation.x: 90 - separation * 75

      PointLight {
        function getNeedleAngle(startAngle) {
          return Math.sin(
                startAngle + (-(180 / 360) + (-gaugeItem.value * meterTicksAngle / 360)
                              + (meterTicksAngle / 2 + 180) / 360) * 2 * Math.PI)
        }

        readonly property real lightRadius: 120
        readonly property real posX: getNeedleAngle(Math.PI) * lightRadius
        readonly property real posY: getNeedleAngle(Math.PI / 2) * lightRadius

        position: Qt.vector3d(posX, 40, -posY)
        color: Qt.rgba(1.0, 0.8, 0.4, 1.0)
        brightness: 25
        quadraticFade: 4.0
      }

      Model {
        y: -4 - separation * 100
        source: "file:///home/draco/QtProjects/Speedometer/meshes/meter_background.mesh"
        scale: Qt.vector3d(30, 30, 30)

        materials: PrincipledMaterial {
          baseColor: "#505050"
          metalness: 1.0
          roughness: 0.6

          normalMap: Texture {
            source: "file:///home/draco/QtProjects/Speedometer/images/leather_n.png"
          }

          normalStrength: 0.4
        }
      }

      Model {
        position: Qt.vector3d(0, 40, 160)
        y: separation * 60 + 20
        source: "#Rectangle"
        scale: Qt.vector3d(0.9, 0.54, 0.8)
        eulerRotation.x: -90

        materials: PrincipledMaterial {
          baseColor: "#808080"
          alphaMode: PrincipledMaterial.Blend
        }
      }

      Model {
        position: Qt.vector3d(0, 40, 160)
        y: separation * 60 + 28
        source: "#Rectangle"
        scale: Qt.vector3d(0.9, 0.54, 10)
        eulerRotation.x: -90

        Text {
          id: digitalSpeed
          color: "white"
          text: (gaugeItem.value * 260).toFixed(0)
          font.pointSize: 30
          anchors.centerIn: parent
        }
      }

      Model {
        y: -35 - separation * 100
        source: "#Sphere"
        scale: Qt.vector3d(1.6, 0.2, 1.6)

        materials: PrincipledMaterial {
          baseColor: "#606060"
        }
      }

      Model {
        y: -separation * 60
        source: "#Cylinder"
        scale: Qt.vector3d(0.2, 0.8, 0.2)

        materials: PrincipledMaterial {
          baseColor: "#606060"
        }
      }

      Model {
        y: 30 - separation * 60
        source: "#Sphere"
        scale: Qt.vector3d(0.4, 0.1, 0.4)

        materials: PrincipledMaterial {
          baseColor: "#f0f0f0"
        }
      }

      Model {
        y: 25 + separation * 20
        source: "#Rectangle"
        scale: Qt.vector3d(4, 4, 4)
        eulerRotation.x: -90

        materials: PrincipledMaterial {
          alphaMode: PrincipledMaterial.Blend
          baseColorMap: Texture {
            source: "file:///home/draco/QtProjects/Speedometer/images/speedometer_labels.png"
          }
        }
      }

      Model {
        y: separation * 60
        source: "file:///home/draco/QtProjects/Speedometer/meshes/meter_edge.mesh"
        scale: Qt.vector3d(30, 30, 30)

        materials: PrincipledMaterial {
          baseColor: "#b0b0b0"
        }
      }

      Node {
        id: gaugeItem

        property real value: 0
        property real needleSize: 180

        y: 20 - separation * 60
        eulerRotation.z: 90
        eulerRotation.y: -meterTicksAngle * value + (meterTicksAngle / 2 - 90)

        Behavior on value {
          SmoothedAnimation {
            id: animation
            velocity: 0.03
            duration: 2000
          }
        }

        Model {
          position.y: gaugeItem.needleSize / 2
          source: "#Cylinder"
          scale: Qt.vector3d(0.05, gaugeItem.needleSize * 0.01, 0.07)

          materials: PrincipledMaterial {
            baseColor: "#606060"
            opacity: particleNeedle ? 0.0 : 1.0
          }
        }
      }
    }

    MouseArea {
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      anchors.fill: parent

      onClicked: mouse => {
                   if (mouse.button === Qt.LeftButton) {
                     separation += 0.1
                   } else if (mouse.button === Qt.RightButton) {
                     separation -= 0.1
                   }
                 }
    }

    Timer {
      id: gaugeTimer
      interval: 50
      repeat: true
      running: false

      onTriggered: {
        gaugeItem.value = Math.max(gaugeItem.value - 0.03, 0)
        if (gaugeItem.value === 0) {
          gaugeTimer.stop()
        }
      }
    }

    property bool isShiftPressed: false

    Keys.onPressed: event => {
                      // @disable-check M127
                      isShiftPressed ? animation.velocity = 0.10 : animation.velocity = 0.03

                      if (event.key === Qt.Key_W) {
                        gaugeItem.value = Math.min(gaugeItem.value + 0.03, 1)
                        console.log("Slow AF")
                        gaugeTimer.stop()
                      }

                      if ((event.key === Qt.Key_W)
                          && (event.modifiers & Qt.ShiftModifier)) {
                        isShiftPressed = true
                        gaugeItem.value = Math.min(gaugeItem.value + 0.10, 1)
                        console.log("BOOOOOSTT")
                        gaugeTimer.stop()
                      }
                    }

    Keys.onReleased: event => {
                       if (event.key === Qt.Key_Shift) {
                         isShiftPressed = false
                       }

                       if (event.key === Qt.Key_W) {
                         gaugeTimer.start()
                       }
                     }
  }
}
