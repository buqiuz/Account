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

import IRadarDataSet from '../interfaces/datasets/IRadarDataSet';
import ColorTemplate from '../utils/ColorTemplate';
import { JArrayList } from '../utils/JArrayList';
import { DataSet } from './DataSet';
import LineRadarDataSet from './LineRadarDataSet';
import RadarEntry from './RadarEntry';

export default class RadarDataSet extends LineRadarDataSet<RadarEntry> implements IRadarDataSet {
  /// flag indicating whether highlight circle should be drawn or not
  protected mDrawHighlightCircleEnabled: boolean = false;
  protected mHighlightCircleFillColor: number = 0xffffff;
  /// The stroke color for highlight circle.
  /// If Utils.COLOR_NONE, the color of the dataset is taken.
  protected mHighlightCircleStrokeColor: number = ColorTemplate.COLOR_NONE;
  protected mHighlightCircleStrokeAlpha: number = Math.floor(0.3 * 255);
  protected mHighlightCircleInnerRadius: number = 3;
  protected mHighlightCircleOuterRadius: number = 4;
  protected mHighlightCircleStrokeWidth: number = 2;

  constructor(yVals: JArrayList<RadarEntry>, label: string) {
    super(yVals, label);
  }

  /// Returns true if highlight circle should be drawn, false if not
  public isDrawHighlightCircleEnabled(): boolean {
    return this.mDrawHighlightCircleEnabled;
  }

  /// Sets whether highlight circle should be drawn or not
  public setDrawHighlightCircleEnabled(enabled: boolean): void {
    this.mDrawHighlightCircleEnabled = enabled;
  }

  public getHighlightCircleFillColor(): number {
    return this.mHighlightCircleFillColor;
  }

  /// Returns the stroke color for highlight circle.
  /// If Utils.COLOR_NONE, the color of the dataset is taken.
  public getHighlightCircleStrokeColor(): number {
    return this.mHighlightCircleStrokeColor;
  }

  public getHighlightCircleStrokeAlpha(): number {
    return this.mHighlightCircleStrokeAlpha;
  }

  public getHighlightCircleInnerRadius(): number {
    return this.mHighlightCircleInnerRadius;
  }

  public getHighlightCircleOuterRadius(): number {
    return this.mHighlightCircleOuterRadius;
  }

  public getHighlightCircleStrokeWidth(): number {
    return this.mHighlightCircleStrokeWidth;
  }

  public copy(): DataSet<RadarEntry> {
    let entries: JArrayList<RadarEntry> = new JArrayList<RadarEntry>();
    if (this.mEntries != null) {
      for (let i = 0; i < this.mEntries.size(); i++) {
        entries.add(this.mEntries.get(i).copy());
      }
    }
    let copied: RadarDataSet = new RadarDataSet(entries, this.getLabel());
    this.copyTo(copied);
    return copied;
  }

  protected copyTo(radarDataSet: RadarDataSet): void {
    super.copyTo(radarDataSet);
    radarDataSet.mDrawHighlightCircleEnabled = this.mDrawHighlightCircleEnabled;
    radarDataSet.mHighlightCircleFillColor = this.mHighlightCircleFillColor;
    radarDataSet.mHighlightCircleInnerRadius = this.mHighlightCircleInnerRadius;
    radarDataSet.mHighlightCircleStrokeAlpha = this.mHighlightCircleStrokeAlpha;
    radarDataSet.mHighlightCircleStrokeColor = this.mHighlightCircleStrokeColor;
    radarDataSet.mHighlightCircleStrokeWidth = this.mHighlightCircleStrokeWidth;
  }
}