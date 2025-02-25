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
import EntryOhos from './EntryOhos';
import ChartPixelMap from './ChartPixelMap';

// @SuppressLint("ParcelCreator")
export default class PieEntry extends EntryOhos {
  public label: string = '';

  constructor(yValue: number, label ?: string, icon ?: ChartPixelMap /*Drawable*/
              , data?: Object) {
    super(0, yValue, icon, data);
    this.label = label ? label : '';
  }

  /**
   * This is the same as getY(). Returns the value of the PieEntry.
   *
   * @return
   */
  public getValue(): number {
    return super.getY();
  }

  public getLabel(): string {
    return this.label;
  }

  public setLabel(label: string): void {
    this.label = label;
  }

  // @Deprecated
  // @Override
  public setX(x: number): void {
    super.setX(x);
    // Log.i("DEPRECATED", "Pie entries do not have x values");
  }

  // @Deprecated
  // @Override
  public getX(): number {
    // Log.i("DEPRECATED", "Pie entries do not have x values");
    return super.getX();
  }

  public copy(): PieEntry {
    let data = this.getData();
    let e: PieEntry = new PieEntry(this.getY(), this.label, undefined, data ? data : undefined);
    return e;
  }
}
