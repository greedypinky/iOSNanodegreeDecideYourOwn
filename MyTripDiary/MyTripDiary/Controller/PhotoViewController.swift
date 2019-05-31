//
//  PhotoViewController.swift
//  MyTripDiary
//
//  Created by Man Wai  Law on 2019-05-28.
//  Copyright © 2019 Rita's company. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    var image:UIImage!
    @IBOutlet weak var selectedPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedPhoto.image = image
        
        addNavigationButton()
    }
    
    private func addNavigationButton(){
        let addButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(share))
        navigationItem.setRightBarButtonItems([addButton], animated: true)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancel))
        navigationItem.setLeftBarButtonItems([cancelButton], animated: true)
        navigationController?.title = "Photo"
    }
    
    
    @objc private func share() {
        print("share")
        let sharedImage = [selectedPhoto.image]
        let ac = UIActivityViewController(activityItems: sharedImage, applicationActivities: nil)
        present(ac, animated: true, completion: nil)
        
    }
    @objc private func cancel() {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
