

import MetalKit

enum PipelineStates {
  static func createPSO(descriptor: MTLRenderPipelineDescriptor)
    -> MTLRenderPipelineState {
    let pipelineState: MTLRenderPipelineState
    do {
      pipelineState =
      try Renderer.device.makeRenderPipelineState(
        descriptor: descriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    return pipelineState
  }

  static func createForwardPSO(colorPixelFormat: MTLPixelFormat) -> MTLRenderPipelineState {
    let vertexFunction = Renderer.library?.makeFunction(name: "vertex_main")
    let fragmentFunction = Renderer.library?.makeFunction(name: "fragment_PBR")
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor =
      MTLVertexDescriptor.defaultLayout
    return createPSO(descriptor: pipelineDescriptor)
  }
  
  static func createObjectIdPSO() -> MTLRenderPipelineState {
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    // 1
    let vertexFunction =
      Renderer.library?.makeFunction(name: "vertex_main")
    let fragmentFunction =
      Renderer.library?.makeFunction(name: "fragment_objectId")
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    // 2
    pipelineDescriptor.colorAttachments[0].pixelFormat = .r32Uint
    // 3
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    pipelineDescriptor.vertexDescriptor =
      MTLVertexDescriptor.defaultLayout
    return Self.createPSO(descriptor: pipelineDescriptor)
  }

}
