//
// faceParsing.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
class faceParsingInput : MLFeatureProvider {

    /// input as color (kCVPixelFormatType_32BGRA) image buffer, 512 pixels wide by 512 pixels high
    var input: CVPixelBuffer

    var featureNames: Set<String> {
        get {
            return ["input"]
        }
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if (featureName == "input") {
            return MLFeatureValue(pixelBuffer: input)
        }
        return nil
    }
    
    init(input: CVPixelBuffer) {
        self.input = input
    }

    convenience init(inputWith input: CGImage) throws {
        self.init(input: try MLFeatureValue(cgImage: input, pixelsWide: 512, pixelsHigh: 512, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    convenience init(inputAt input: URL) throws {
        self.init(input: try MLFeatureValue(imageAt: input, pixelsWide: 512, pixelsHigh: 512, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    func setInput(with input: CGImage) throws  {
        self.input = try MLFeatureValue(cgImage: input, pixelsWide: 512, pixelsHigh: 512, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setInput(with input: URL) throws  {
        self.input = try MLFeatureValue(imageAt: input, pixelsWide: 512, pixelsHigh: 512, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
class faceParsingOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// argmax_out as multidimensional array of floats
    lazy var argmax_out: MLMultiArray = {
        [unowned self] in return self.provider.featureValue(for: "argmax_out")!.multiArrayValue
    }()!

    /// argmax_out as multidimensional array of floats
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    var argmax_outShapedArray: MLShapedArray<Float> {
        return MLShapedArray<Float>(self.argmax_out)
    }

    var featureNames: Set<String> {
        return self.provider.featureNames
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return self.provider.featureValue(for: featureName)
    }

    init(argmax_out: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["argmax_out" : MLFeatureValue(multiArray: argmax_out)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 11.0, iOS 14.0, tvOS 14.0, watchOS 7.0, *)
class faceParsing {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "faceParsing", withExtension:"mlmodelc")!
    }

    /**
        Construct faceParsing instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of faceParsing.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `faceParsing.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct faceParsing instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct faceParsing instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<faceParsing, Error>) -> Void) {
        return self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct faceParsing instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> faceParsing {
        return try await self.load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct faceParsing instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<faceParsing, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(faceParsing(model: model)))
            }
        }
    }

    /**
        Construct faceParsing instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> faceParsing {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return faceParsing(model: model)
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as faceParsingInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as faceParsingOutput
    */
    func prediction(input: faceParsingInput) throws -> faceParsingOutput {
        return try self.prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        - parameters:
           - input: the input to the prediction as faceParsingInput
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as faceParsingOutput
    */
    func prediction(input: faceParsingInput, options: MLPredictionOptions) throws -> faceParsingOutput {
        let outFeatures = try model.prediction(from: input, options:options)
        return faceParsingOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        - parameters:
            - input as color (kCVPixelFormatType_32BGRA) image buffer, 512 pixels wide by 512 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as faceParsingOutput
    */
    func prediction(input: CVPixelBuffer) throws -> faceParsingOutput {
        let input_ = faceParsingInput(input: input)
        return try self.prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        - parameters:
           - inputs: the inputs to the prediction as [faceParsingInput]
           - options: prediction options 

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [faceParsingOutput]
    */
    func predictions(inputs: [faceParsingInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [faceParsingOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [faceParsingOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  faceParsingOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
