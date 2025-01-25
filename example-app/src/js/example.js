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

window.openCamera = openCamera
window.closeCamera = closeCamera
window.takePicture = takePicture

