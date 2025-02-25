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

export default class CandleEntry extends EntryOhos {
  private mShadowHigh: number = 0.0;
  private mShadowLow: number = 0.0;
  private mClose: number = 0.0;
  private mOpen: number = 0.0;

  constructor(x: number, shadowH: number, shadowL: number, open: number, close: number, icon?: ChartPixelMap, data?: object) {
    super(x, (shadowH + shadowL) / 2.0, icon, data);
    this.mShadowHigh = shadowH ? shadowH : 0;
    this.mShadowLow = shadowL ? shadowL : 0;
    this.mOpen = open ? open : 0;
    this.mClose = close ? close : 0;
  }

  public getShadowRange(): number {
    return Math.abs(this.mShadowHigh - this.mShadowLow);
  }

  public getBodyRange(): number {
    return Math.abs(this.mOpen - this.mClose);
  }

  public getY(): number {
    return super.getY();
  }

  public copy(): CandleEntry {
    let data: object | null = this.getData();
    if (!data) {
      return new CandleEntry(this.getX(), this.mShadowHigh, this.mShadowLow, this.mOpen, this.mClose);
    } else {
      return new CandleEntry(this.getX(), this.mShadowHigh, this.mShadowLow, this.mOpen, this.mClose, undefined, data);
    }
  }

  public getHigh(): number {
    return this.mShadowHigh;
  }

  public setHigh(shadowH: number): void {
    this.mShadowHigh = shadowH;
  }

  public getLow(): number {
    return this.mShadowLow;
  }

  public setLow(shadowL: number): void {
    this.mShadowLow = shadowL
  }

  public getClose(): number {
    return this.mClose;
  }

  public setClose(close: number): void {
    this.mClose = close
  }

  public getOpen(): number {
    return this.mOpen;
  }

  public setOpen(open: number): void {
    this.mOpen = open
  }
};
