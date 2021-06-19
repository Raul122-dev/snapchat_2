import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegistrarUsuarioViewController: UIViewController {

    @IBOutlet weak var usuariotxt: UITextField!
    @IBOutlet weak var passtxt: UITextField!
    @IBOutlet weak var cpasstxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
        
    @IBAction func registrarTapped(_ sender: Any) {
        let password = passtxt.text!
        let cpassword = cpasstxt.text!
        if(password.count > 0 && password == cpassword){
            Auth.auth().createUser(withEmail: self.usuariotxt.text!, password: self.passtxt.text!, completion: {(user,error) in
            print("Intentando crear un usuario")
            if error != nil{
                print("Se presentó el siguiente error al crear el usuario: \(error)")
                }else{
                    print("El usuario fué creado exitosamente")
                    Database.database().reference().child("usuarios").child(user!.user.uid).child("email").setValue(user!.user.email)
                    
                    let alerta = UIAlertController(title: "Creación de Usuario", message: "Usuario \(self.usuariotxt.text!) se creo correctamente.", preferredStyle: .alert)
                    let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                        self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)})
                    alerta.addAction(btnOK)
                    self.present(alerta, animated: true, completion: nil)
                }})
        }else{
            var alerta:UIAlertController? = nil
            if(password != cpassword){
                alerta = UIAlertController(title: "Creación de Usuario",message: "Las contraseñas no coinciden.", preferredStyle: .alert)
            }else{
                alerta = UIAlertController(title: "Creación de Usuario",message: "La contraseña debe tener mas de 1 caracter", preferredStyle: .alert)
            }
            let btnOK = UIAlertAction(title: "Aceptar", style: .default, handler: {(UIAlertAction) in
                })
            alerta?.addAction(btnOK)
            self.present(alerta!, animated: true, completion: nil)
        }
    }
}
