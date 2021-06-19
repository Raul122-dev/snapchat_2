import UIKit
import Firebase
import FirebaseStorage
import AVFoundation

class ImagenViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descripcionTextField: UITextField!
    @IBOutlet weak var elegirContactoBoton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var duracionLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    var imagenID = NSUUID().uuidString
    var audioID = NSUUID().uuidString
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var counter = 0
    var timer = Timer()
    var verifImage = false
    var verifAudio = false
    
    func configurarGrabacion() {
        do {
            // Creacion de sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)

            // Creacion de direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!

            // Creacion opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?

            // Creacion del objeto para grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()

        } catch let error as NSError {
            print(error)
        }
    }
    
    func segundosFormato (_ seconds : Int) -> (String, String, String) {
        let segundos:String = String(format: "%02d",seconds / 3600)
        let minutos:String = String(format: "%02d",(seconds % 3600) / 60)
        let horas:String = String(format: "%02d",(seconds % 3600) % 60)
      return (segundos, minutos, horas)
    }
    
    func validarContenido () {
        print("imagen: \(verifImage)")
        print("audio: \(verifAudio)")
        if(verifImage && verifAudio){
            elegirContactoBoton.isEnabled = true
            print("activado")
        }else{
            elegirContactoBoton.isEnabled = false
            print("desactivado")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        elegirContactoBoton.isEnabled = false
        configurarGrabacion()
        reproducirButton.isEnabled = false
    }
    
    @IBAction func camaraTapped(_ sender: Any) {
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func mediaTapped(_ sender: Any) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            // Detener grabacion
            grabarAudio?.stop()
            
            // Cambiar texto del botòn grabar
            grabarButton.setTitle("Grabar", for: .normal)
            reproducirButton.isEnabled = true
            verifAudio = true
            validarContenido()
            timer.invalidate()
            
        } else {
            // Empezar a grabar
            grabarAudio?.record()
            counter = 0
            // Cambiar texto del botòn grabar a detener
            grabarButton.setTitle("Detener", for: .normal)
            reproducirButton.isEnabled = false
            verifAudio = false
            validarContenido()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        }catch {}
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageView.image = image
        imageView.backgroundColor = UIColor.clear
        verifImage = true
        validarContenido()
        imagePicker.dismiss(animated:true, completion: nil)
    }
    
    func mostrarAlerta(titulo:String, mensaje: String, accion: String){
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let btnCANCELOK = UIAlertAction(title: accion, style: .default, handler: nil)
        alerta.addAction(btnCANCELOK)
        present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func elegirContactoTapped(_ sender: Any) {
        self.elegirContactoBoton.isEnabled = false
        let imagenesFolder = Storage.storage().reference().child("imagenes")
        let audiosFolder = Storage.storage().reference().child("audios")
        let imagenData = imageView.image?.jpegData(compressionQuality: 0.50)
        let cargarImagen = imagenesFolder.child("\(imagenID).jpg")
        cargarImagen.putData(imagenData!, metadata: nil){(metadata, error) in
            if error != nil{
                self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir la imagen. Verifique su conexion a internet y vuelve a intentarlo.", accion: "Aceptar")
                self.elegirContactoBoton.isEnabled = true
                print("Ocurrio un error al subir su imagen: \(error!)")
            }else{
                cargarImagen.downloadURL(completion: {(url, error) in
                    guard let enlaceURL = url else{
                        self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de imagen.", accion: "Cancelar")
                        self.elegirContactoBoton.isEnabled = true
                        print("Ocurrio un error al obtener informacion de imagen \(error!)")
                        return
                    }
                    let urlimg = url?.absoluteString
                    let cargarAudio = audiosFolder.child("\(self.audioID).m4a")
                    cargarAudio.putData(NSData(contentsOf: self.audioURL!)! as Data, metadata: nil){(metadata, error) in
                        if error != nil{
                            self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al subir el audio. Verifique su conexion a internet y vuelve a intentarlo.", accion: "Aceptar")
                            self.elegirContactoBoton.isEnabled = true
                            print("Ocurrio un error al subir su audio: \(error!)")
                        }else{
                            cargarAudio.downloadURL(completion: {(url, error) in
                                guard let enlaceURL = url else{
                                    self.mostrarAlerta(titulo: "Error", mensaje: "Se produjo un error al obtener información de audio.", accion: "Cancelar")
                                    self.elegirContactoBoton.isEnabled = true
                                    print("Ocurrio un error al obtener informacion de audio \(error!)")
                                    return
                                }
                                self.performSegue(withIdentifier: "seleccionarContactoSegue", sender: [urlimg,url?.absoluteString])
                            })
                        }
                    }
                })
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let siguienteVC = segue.destination as! ElegirUsuarioViewController
        let datos = sender as! [String]
        siguienteVC.imagenURL = datos[0]
        siguienteVC.audioURL = datos[1]
        siguienteVC.descrip = descripcionTextField.text!
        siguienteVC.imagenID = imagenID
        siguienteVC.audioID = audioID
    }
    
    @objc func timerAction() {
        counter += 1
        let (h,m,s) = segundosFormato(counter)
        duracionLabel.text = "Duracion: \(h):\(m):\(s)"
    }
}
