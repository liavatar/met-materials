import MetalKit

struct ObjectIdRenderPass: RenderPass {
  let label = "Object ID Render Pass"
  var descriptor: MTLRenderPassDescriptor?
  var pipelineState: MTLRenderPipelineState

  var idTexture: MTLTexture?
  var depthTexture: MTLTexture?
  var depthStencilState: MTLDepthStencilState?

  mutating func resize(view: MTKView, size: CGSize) {

    idTexture = Self.makeTexture(
      size: size,
      pixelFormat: .r32Uint,
      label: "ID Texture")
    
    depthTexture = Self.makeTexture(
      size: size,
      pixelFormat: .depth32Float,
      label: "ID Depth Texture")
  }

  init() {
    pipelineState = PipelineStates.createObjectIdPSO()
    descriptor = MTLRenderPassDescriptor()
    depthStencilState = Self.buildDepthStencilState()
  }

  func draw(
    commandBuffer: MTLCommandBuffer,
    scene: GameScene,
    uniforms: Uniforms,
    params: Params ) {
    
      guard let descriptor = descriptor else {
        return
      }
      descriptor.colorAttachments[0].texture = idTexture
      descriptor.colorAttachments[0].loadAction = .clear
      descriptor.colorAttachments[0].storeAction = .store

      descriptor.depthAttachment.texture = depthTexture

      /*
       You assign idTexture to the descriptor’s first color attachment. The pixel format must match the render target textures when configuring the color attachment for the pipeline state object. In this case, you set them both to r32Uint.
       */
      
      guard let renderEncoder =
              commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
      else {
        return
      }
      
      renderEncoder.label = label
      renderEncoder.setRenderPipelineState(pipelineState)
      renderEncoder.setDepthStencilState(depthStencilState)

      for model in scene.models {
        model.render(
          encoder: renderEncoder,
          uniforms: uniforms,
          params: params)
      }
      renderEncoder.endEncoding()

  }
}

