//
//  ViewController.swift
//  Snapchat
//
//  Created by Javier Flores Càrdenas on 5/26/21.
//  Copyright © 2021 Javier Flores Càrdenas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase

class iniciarSesionViewController: UIViewController, GIDSignInDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func iniciarSesionTapped(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){(user,error) in
            print("Intentando Iniciar Sesion")
            if error != nil{
                print("Se presentó el siguiente error: \(error!)")
                let alerta = UIAlertController(title: "Login de Usuario",message: "No se encontrò ningùn usuario con estas credenciales.", preferredStyle: .alert)
                let btnOK = UIAlertAction(title: "Crear", style: .default, handler: {(UIAlertAction) in
                    self.performSegue(withIdentifier: "createUserSegue", sender: nil)})
                let btnCancel = UIAlertAction(title: "Cancelar", style: .default, handler: {(UIAlertAction) in })
                alerta.addAction(btnOK)
                alerta.addAction(btnCancel)
                self.present(alerta, animated: true, completion: nil)
                
            }else{
                print("Inicio de sesión exitoso")
                self.performSegue(withIdentifier: "iniciarsesionsegue", sender: nil)
            }
        }
    }
    @IBAction func iniciarSesionGoogleTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @IBAction func crearUsuarioTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "createUserSegue", sender: nil)
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil{
            let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            Auth.auth().signIn(with: credential){(user,error) in
                if error != nil{
                    print("Se presentó el siguiente error: \(String(describing: error))")
                }else{
                    print("Inicio de sesión con google exitoso")
                }
            }
            
        }
    }

}

