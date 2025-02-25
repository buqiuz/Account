/*
 * Copyright (C) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import  image  from '@ohos.multimedia.image';

export default class ChartPixelMap {
  private icon: PixelMap | number | null = null;
  private height: number = 0;
  private width: number = 0;

  //设置图标 PixelMap 或者 Resource.id
  public setIcon(newIcon: PixelMap| number) {
    this.icon = newIcon;
  }

  public async getIcon(): Promise<image.PixelMap | null> {
    if (typeof this.icon === 'number') {
      let id = this.icon as  number
      let fileData = getContext(this).resourceManager.getMediaContentSync(id)
      const buffer:ArrayBuffer =fileData.buffer.slice(0,fileData.buffer.byteLength);
      const imageSource:image.ImageSource = image.createImageSource(buffer)
      let pixelMap= await imageSource.createPixelMap()
      return pixelMap
    }

    if (this.icon != null) {
      let pixelMap = this.icon as  PixelMap
      return pixelMap;
    }

    return null
  }

  public setWidth(width: number) {
    this.width = width;
  }

  public getWidth(): number {
    return this.width;
  }

  public setHeight(height: number) {
    this.height = height;
  }

  public getHeight(): number {
    return this.height;
  }
}