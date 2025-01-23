import { Ricoh360Camera } from 'richon360-camera';

async function getCameraSizes() {
    const sizes =  await Ricoh360Camera.initialize({ language: 'en-US', cameraUrl: 'http://192.168.1.1:3000' })  // await CameraPreview.getSupportedPictureSizes()
    console.log(sizes)
    await Ricoh360Camera.livePreview()
  }

window.testEcho = () => {
    // const inputValue = document.getElementById("echoInput").value;
    // Ricoh360Camera.echo({ value: inputValue })
    getCameraSizes()
}

