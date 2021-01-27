//
//  CreateStoresController.swift
//  GroceryShopping
//
//  Created by Saahil Sukhija on 1/17/21.
//

import UIKit

class CreateStoresController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIButton!
    var listOfStores = [UIView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        doneButton.layer.cornerRadius = 10
        tableView.dataSource = self
        tableView.layer.borderColor = UIColor.gray.cgColor
        tableView.layer.borderWidth = 0.5
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view.
        hideKeyboardWhenTappedAround()
        addTextFieldToTableView()
    }
    
    func addTextFieldToTableView()
    {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        textField.setLeftPaddingPoints(20)
        textField.backgroundColor = .clear
        textField.placeholder = "Add new store..."
        textField.returnKeyType = .done
        textField.delegate = self
        textField.autocapitalizationType = .words
        
        if listOfStores.count != 0 {
            textField.becomeFirstResponder()
        }
        addTextFieldToList(textField)
    }
    
    func addLabelToList(_ label: UILabel)
    {
        self.listOfStores.append(label)
        let indexPath = IndexPath(row: listOfStores.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
    }
    
    func addTextFieldToList(_ field: UITextField)
    {
        listOfStores.append(field)
        let indexPath = IndexPath(row: listOfStores.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .left)
    }
    
    func turnTextFieldIntoLabel(textField: UITextField) {
        //Get all names
        
        let label = PaddingLabel(frame: textField.frame)
        label.text = textField.text
        label.backgroundColor = .clear
        label.textInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        label.textColor = .label
        addLabelToList(label)
        
        UIView.setAnimationsEnabled(false)
        //Delete TextField
        let indexPath = IndexPath(item: listOfStores.count - 2, section: 0)
        listOfStores.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .none)
        UIView.setAnimationsEnabled(true)
        
        addTextFieldToTableView()
        
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        let stores = getAllUserStores()
        if stores.isEmpty {
            Alert.regularAlert(title: "No Stores Entered!", message: "Please enter at least one store. Note: Selections can be changed later", vc: self)
        }
        else {
            updateUserStores(stores: stores)
            backToHome()
        }
    }
    
    func backToHome() {
        UserDefaults.standard.set(true, forKey: "hasLaunched")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: "tabBar")
        home.modalPresentationStyle = .fullScreen
        self.present(home, animated: true, completion: nil)
    }
    func updateUserStores(stores: [Store]) {
        // TODO: upload to user's cloud
        do {
            try UserDefaults.standard.set(object: stores, forKey: "stores")
        } catch {
            print("error saving")
        }
        
        /*do {
            let data = try UserDefaults.standard.get(objectType: [Store].self, forKey: "stores")
            print(data)
        } catch {
            print("error retrieving")
        }*/
    }
    func getAllUserStores() -> [Store]{
        var names = [Store]()
        
        for view in listOfStores {
            if view as? UITextField == nil {
                let storeName = (view as! UILabel).text!
                names.append(Store(name: storeName))
            }
        }
        return names
    }
    
    
}


extension CreateStoresController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if(textField.text == "") {
    
            Alert.regularAlert(title: "Empty Store!", message: "Text Field is empty, please try again", vc: self)
        }
        else {
            DispatchQueue.main.async {
                self.turnTextFieldIntoLabel(textField: textField)
            }
        }
        return true
    }
}
extension CreateStoresController: UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfStores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = UITableViewCell()
        newCell.contentView.addSubview(listOfStores[indexPath.row])
        newCell.preservesSuperviewLayoutMargins = false
        newCell.separatorInset = UIEdgeInsets.zero
        newCell.layoutMargins = UIEdgeInsets.zero
        return newCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (listOfStores[indexPath.row] as? UITextField == nil) {
            guard editingStyle == .delete else { return }
            listOfStores.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
    

extension UIViewController{
    func hideKeyboardWhenTappedAround(){
        let tapOff = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard));
        view.addGestureRecognizer(tapOff);
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true);
    }
}


//MARK: Setting margins
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

@IBDesignable class PaddingLabel: UILabel {
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

/*Borders
extension UIView {
    func addBottomBorder(color: UIColor? = .gray, width: CGFloat = 0.5) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - width, width: frame.size.width, height: width)
        addSubview(border)
    }
}
*/
