/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
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

import BarEntry from './BarEntry';
import ChartPixelMap from './ChartPixelMap';

export class WaterfallHighlight {
  private minY: number = 0;
  private maxY: number = 0;
  private color: string | number = "#ff0000";

  constructor(minY: number, maxY: number, color?: string | number) {
    this.minY = minY;
    this.maxY = maxY;
    if (color != undefined) {
      this.color = color;
    }
  }

  getMinY() {
    return this.minY;
  }

  getMaxY() {
    return this.maxY;
  }

  getColor() {
    return this.color;
  }

  setColor(color: string | number) {
    this.color = color;
  }
}

export default class WaterfallEntry extends BarEntry {
  private mMinY: number = 0;
  private mMaxY: number = 0;
  private mHighlights: WaterfallHighlight[] = [];

  constructor(x?: number, minY?: number, maxY?: number, icon?: ChartPixelMap, data?: Object, ...highlights: WaterfallHighlight[]) {
    super(x, maxY, icon, data);
    this.mMinY = minY ? minY : 0;
    this.mMaxY = maxY ? maxY : 0;
    this.mHighlights = highlights;
  }

  public getMinY(): number {
    return this.mMinY;
  }

  public getMaxY(): number {
    return super.getY();
  }

  public getHighlights(): WaterfallHighlight[] {
    return this.mHighlights;
  }

  public setHighlights(...highlights: WaterfallHighlight[]): void {
    for (const highlight of highlights) {
      let exists = false;
      for (const existingHighlight of this.mHighlights) {
        if (
          existingHighlight.getMinY() === highlight.getMinY() &&
            existingHighlight.getMaxY() === highlight.getMaxY() &&
            existingHighlight.getColor() === highlight.getColor()
        ) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        this.mHighlights.push(highlight);
      }
    }
  }
}
