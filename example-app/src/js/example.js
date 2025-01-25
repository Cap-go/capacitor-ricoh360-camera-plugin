import { Ricoh360Camera } from 'ricoh360-camera';

async function openCamera() {
    const ip = document.getElementById("ipInput").value
    try {
        await Ricoh360Camera.initialize({
            url: `http://${ip}`
        })
        document.getElementById('mainContent').style.display = 'none'
        document.getElementById('cameraPreview').style.display = 'block'
        await Ricoh360Camera.livePreview({ displayInFront: false })
        console.log("Camera opened")
    } catch (e) {
        console.error(e)
    }
}

async function closeCamera() {
    try {
        await Ricoh360Camera.stopLivePreview()
        document.getElementById('cameraPreview').style.display = 'none'
        document.getElementById('mainContent').style.display = 'block'
    } catch (e) {
        console.error(e)
    }
}

async function takePicture() {
    try {
        const result = await Ricoh360Camera.capturePicture()
        if (result?.picture?.results?.fileUrl) {
            document.getElementById('lastPicture').src = result.picture.results.fileUrl
        }
    } catch (e) {
        console.error(e)
    }
}

async function readSettings() {
    try {
        const optionsToRead = [
            "iso",
            "shutterSpeed",
            "whiteBalance",
            "exposureProgram",
            "exposureCompensation",
            "fileFormat"
        ]
        const result = await Ricoh360Camera.readSettings({ options: optionsToRead })
        document.getElementById('settingsValue').textContent = JSON.stringify(result, null, 2)
    } catch (e) {
        console.error(e)
        document.getElementById('settingsValue').textContent = `Error: ${e.message}`
    }
}

async function setSettings() {
    try {
        const settings = {
            iso: 200,
            // shutterSpeed: 0.01,
            // whiteBalance: 'auto',
            // exposureProgram: 2, // Normal program
            // exposureCompensation: 0.0,
            // "fileFormat": {
            //     "type": "jpeg",
            //     "width": 2048,
            //     "height": 1024
            // }
        }
        const result = await Ricoh360Camera.setSettings({ options: settings })
        document.getElementById('settingsValue').textContent = JSON.stringify(result, null, 2)
    } catch (e) {
        console.error(e)
        document.getElementById('settingsValue').textContent = `Error: ${e.message}`
    }
}

async function sendCommand() {
    try {
        const result = await Ricoh360Camera.sendCommand({
            endpoint: '/osc/commands/execute',
            payload: {
                name: "camera.getOptions",
                parameters: {
                    optionNames: ["shutterSpeed", "iso"]
                }
            }
        })
        document.getElementById('settingsValue').textContent = JSON.stringify(result, null, 2)
    } catch (e) {
        console.error(e)
        document.getElementById('settingsValue').textContent = `Error: ${e.message}`
    }
}

window.openCamera = openCamera
window.closeCamera = closeCamera
window.takePicture = takePicture
window.readSettings = readSettings
window.setSettings = setSettings
window.sendCommand = sendCommand

