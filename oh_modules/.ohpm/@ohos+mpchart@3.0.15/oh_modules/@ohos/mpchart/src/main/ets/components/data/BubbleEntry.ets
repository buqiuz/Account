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

export default class BubbleEntry extends EntryOhos {
  private mSize: number = 0.0;

  constructor(x: number, y?: number, size?: number, icon?: ChartPixelMap, data?: Object) {
    super(x, y, icon, data);
    this.mSize = size ? size : 0;
  }

  public copy(): BubbleEntry {
    let data: Object | null = this.getData();
    if (!data) {
      return new BubbleEntry(this.getX(), this.getY(), this.mSize);
    } else {
      return new BubbleEntry(this.getX(), this.getY(), this.mSize, undefined, data);
    }
  }

  public getSize(): number {
    return this.mSize;
  }

  public setSize(size: number): void {
    this.mSize = size
  }
};
