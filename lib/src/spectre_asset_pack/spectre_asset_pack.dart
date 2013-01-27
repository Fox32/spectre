/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

part of spectre_asset_pack;

/** Register the [spectre] graphics device with the [asset_pack]
 * asset manager. After calling this function, the asset manager
 * will be able to load meshes, textures, and shaders.
 */
void registerSpectreWithAssetManager(GraphicsDevice graphicsDevice,
                                         AssetManager assetManager) {
  assetManager.loaders['mesh'] = new AssetLoaderText();
  assetManager.loaders['tex2d'] = new AssetLoaderImage();
  assetManager.loaders['texCube'] = new _ImagePackLoader();
  assetManager.loaders['vertexShader'] = new AssetLoaderText();
  assetManager.loaders['fragmentShader'] = new AssetLoaderText();
  assetManager.loaders['shaderProgram'] = new _TextListLoader();

  assetManager.importers['mesh'] = new _AssetImporterMesh(graphicsDevice);
  assetManager.importers['tex2d'] = new _AssetImporterTex2D(graphicsDevice);
  assetManager.importers['texCube'] = new _AssetImporterTexCube(graphicsDevice);
  assetManager.importers['vertexShader'] =
      new _AssetImporterVertexShader(graphicsDevice);
  assetManager.importers['fragmentShader'] =
      new _AssetImporterFragmentShader(graphicsDevice);
  assetManager.importers['shaderProgram'] =
      new _AssetImporterShaderProgram(graphicsDevice);
}