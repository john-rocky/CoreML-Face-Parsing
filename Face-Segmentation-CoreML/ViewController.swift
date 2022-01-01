//
//  ViewController.swift
//  Face-Segmentation-CoreML
//
//  Created by 間嶋大輔 on 2022/01/02.
//

import UIKit
import Vision
import PhotosUI

class ViewController: UIViewController, PHPickerViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    

    var coreMLRequest:VNCoreMLRequest?
    var selectedImage:UIImage?
    
    var outputTypes:[String] = ["all","skin","eyeBrowLeft","eyeBrowRight","eyeLeft","eyeRight","nose","teeth","lipUpper","lipLower","neck","cloth","hair","hat"]
    var outputType:OutputType = .all
    
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var outputImageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCoreMLModel()
        presentPhPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func initializeCoreMLModel() {
        do {
            let model = try faceParsing(configuration: MLModelConfiguration()).model
            let vnCoreMLModel = try VNCoreMLModel(for: model)
            let request = VNCoreMLRequest(model: vnCoreMLModel)
            request.imageCropAndScaleOption = .scaleFill
            coreMLRequest = request
        } catch let error {
            print(error)
        }
    }
    
    func inference(uiImage: UIImage) {
        guard let coreMLRequest = coreMLRequest else {fatalError("Model initialization failed.")}
        guard let ciImage = CIImage(image: uiImage) else {fatalError("Image failed.")}
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        do {
            try handler.perform([coreMLRequest])
            guard let result = coreMLRequest.results?.first as? VNCoreMLFeatureValueObservation else {fatalError("Inference failed.")}
            let multiArray = result.featureValue.multiArrayValue
            guard let  outputCGImage = multiArray?.cgImage(min: 0, max: 18, channel: nil, outputType: outputType.rawValue) else {fatalError("Image processing failed.")}
            DispatchQueue.main.async { [weak self] in
                let outputUIImage = UIImage(cgImage: outputCGImage)
                self?.outputImageView.image = outputUIImage
            }
        } catch let error {
            print(error)
        }
    }
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error  in
                if let image = image as? UIImage,  let safeSelf = self {
                    let correctOrientImage = safeSelf.getCorrectOrientationUIImage(uiImage: image)
                    safeSelf.selectedImage = correctOrientImage
                    DispatchQueue.main.async {
                        safeSelf.originalImageView.image = correctOrientImage
                    }
                    safeSelf.inference(uiImage: correctOrientImage)
                }
            }
        }
    }
    
    func presentPhPicker(){
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction func selectPhotoButton(_ sender: UIButton) {
        presentPhPicker()
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        guard let outputImage = outputImageView.image else { return }
        UIImageWriteToSavedPhotosAlbum(outputImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return outputTypes.count
    }
     
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return outputTypes[row]
    }
     
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        let selectedOutputType = outputTypes[row]
        switch selectedOutputType {
        case "all":
            outputType = .all
        case "skin":
            outputType = .skin
        case "eyeBrowLeft":
            outputType = .eyeBrowLeft
        case "eyeBrowRight":
            outputType = .eyeBrowRight
        case "eyeLeft":
            outputType = .eyeLeft
        case "eyeRight":
            outputType = .eyeRight
        case "nose":
            outputType = .nose
        case "teeth":
            outputType = .teeth
        case "lipUpper":
            outputType = .lipUpper
        case "lipLower":
            outputType = .lipLower
        case "neck":
            outputType = .neck
        case "cloth":
            outputType = .cloth
        case "hair":
            outputType = .hair
        case "hat":
            outputType = .hat
        default:
            break
        }
        guard let selectedImage = selectedImage else {
            return
        }
        inference(uiImage: selectedImage)
    }

    func getCorrectOrientationUIImage(uiImage:UIImage) -> UIImage {
        var newImage = UIImage()
        let ciContext = CIContext()
        switch uiImage.imageOrientation.rawValue {
        case 1:
            guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.down),
                  let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
            
            newImage = UIImage(cgImage: cgImage)
        case 3:
            guard let orientedCIImage = CIImage(image: uiImage)?.oriented(CGImagePropertyOrientation.right),
                  let cgImage = ciContext.createCGImage(orientedCIImage, from: orientedCIImage.extent) else { return uiImage}
            newImage = UIImage(cgImage: cgImage)
        default:
            newImage = uiImage
        }
        return newImage
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: NSLocalizedString("saved!",value: "saved!", comment: ""), message: NSLocalizedString("Saved in photo library",value: "Saved in photo library", comment: ""), preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

}

enum OutputType: Int {
    typealias RawValue = Int
    case all = 0
    case skin = 1
    case eyeBrowLeft = 2
    case eyeBrowRight = 3
    case eyeLeft = 4
    case eyeRight = 5
    case nose = 10
    case teeth = 11
    case lipUpper = 12
    case lipLower = 13
    case neck = 14
    case cloth = 16
    case hair = 17
    case hat = 18
}
