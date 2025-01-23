import { Ricoh360Camera } from 'richon360-camera';

async function openCamera() {
    const ip = document.getElementById("ipInput").value
    console.log(`http://${ip}`)
    const sizes =  await Ricoh360Camera
    .initialize({ language: 'en-US', cameraUrl: `http://${ip}` })
    .catch(e => {
        console.log(e)
    })
    console.log(sizes)
    await Ricoh360Camera
    .livePreview()
    .catch(e => {
        console.log(e)
    })

  }

window.testCamera = () => {
    openCamera().then(() => {
        console.log("Camera opened")
    }).catch(e => {
        console.log(e)
    })
}

