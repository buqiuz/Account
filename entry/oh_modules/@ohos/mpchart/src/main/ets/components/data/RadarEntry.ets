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

import ChartPixelMap from './ChartPixelMap';
import EntryOhos from './EntryOhos';

export default class RadarEntry extends EntryOhos {
  constructor(value: number, icon ?: ChartPixelMap,data?: Object) {
    super(0, value, icon, data);
  }

  public getValue(): number {
    return this.getY();
  }

  public copy(): RadarEntry {
    if (!this.getData()) {
      return new RadarEntry(this.getY(), undefined);
    }
    let e: RadarEntry = new RadarEntry(this.getY(),this.getIcon()!, this.getData()!);
    return e;
  }

  public setX(x: number) {
    super.setX(x);
  }

  public getX(): number {
    return super.getX();
  }
}