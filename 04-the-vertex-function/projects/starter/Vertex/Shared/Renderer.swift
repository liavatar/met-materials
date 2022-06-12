

import MetalKit

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  var pipelineState: MTLRenderPipelineState!
  
  // MARK: - adding quad and timer
  var timer: Float = 0
  // because we initialize device in init(metalView:), we must initialize quad lazily
  lazy var quad: Quad = {
    Quad(device: Renderer.device, scale: 0.8)
  }()

  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("GPU not available")
    }
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    metalView.device = device

    // create the shader function library
    let library = device.makeDefaultLibrary()
    Self.library = library
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction =
      library?.makeFunction(name: "fragment_main")

    // create the pipeline state object
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat =
      metalView.colorPixelFormat
    
    // MARK: - 3, adding vertex descriptor
    pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout

    do {
      pipelineState =
        try device.makeRenderPipelineState(
          descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }

    super.init()
    metalView.clearColor = MTLClearColor(
      red: 1.0,
      green: 1.0,
      blue: 0.8,
      alpha: 1.0)
    metalView.delegate = self
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(
    _ view: MTKView,
    drawableSizeWillChange size: CGSize
  ) {
  }

  func draw(in view: MTKView) {
    guard
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
      let descriptor = view.currentRenderPassDescriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor) else {
        return
    }
    
    renderEncoder.setRenderPipelineState(pipelineState)
    
    // MARK: - send timer to GPU
    timer += 0.005
    var currentTime = sin(timer)
    renderEncoder.setVertexBytes(
      &currentTime,
      length: MemoryLayout<Float>.stride,
      index: 11)

    // do drawing here
    // MARK: - quad rendering
    renderEncoder.setVertexBuffer(
      quad.vertexBuffer,
      offset: 0,
      index: 0)
    
//    renderEncoder.drawPrimitives(
//      type: .triangle,
//      vertexStart: 0,
//      vertexCount: quad.vertices.count)

//    // MARK: - 2 quad rendering using vertex index
//    renderEncoder.setVertexBuffer(
//      quad.indexBuffer,
//      offset: 0,
//      index: 1)
//    renderEncoder.drawPrimitives(
//      type: .triangle,
//      vertexStart: 0,
//      vertexCount: quad.indices.count)
    
    // MARK: - 4 adding color buffer
    renderEncoder.setVertexBuffer(
      quad.colorBuffer,
      offset: 0,
      index: 1)

    // MARK: - 3 using vertex descriptor and indexedPrimitive to draw
    renderEncoder.drawIndexedPrimitives(
      // type: .triangle,
      type: .point,
      indexCount: quad.indices.count,
      indexType: .uint16,
      indexBuffer: quad.indexBuffer,
      indexBufferOffset: 0)

    
    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
