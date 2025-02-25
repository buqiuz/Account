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

import ChartModel from '../charts/ChartModel';
import ChartData from '../data/ChartData';
import EntryOhos from '../data/EntryOhos';
import Highlight from '../highlight/Highlight';
import IDataSet from '../interfaces/datasets/IDataSet';
import MPPointF from '../utils/MPPointF';
import IMarker from './IMarker';

export default class MarkerView implements IMarker {
  private mOffset: MPPointF = new MPPointF();
  private mOffset2: MPPointF = new MPPointF();
  private mWeakChart: ChartModel<ChartData<IDataSet<EntryOhos>>> | null = null;

  constructor() {
  }

  public setOffsetByMPPointF(offset: MPPointF) {
    this.mOffset = offset;

    if (this.mOffset == null) {
      this.mOffset = new MPPointF();
    }
  }

  public setOffset(offsetX: number, offsetY: number): void {
    this.mOffset.x = offsetX;
    this.mOffset.y = offsetY;
  }

  getOffset(): MPPointF {
    return this.mOffset;
  }

  public setChartView(chart: ChartModel<ChartData<IDataSet<EntryOhos>>>): void {
    this.mWeakChart = chart;
  }

  public getChartView(): ChartModel<ChartData<IDataSet<EntryOhos>>> | null {
    return this.mWeakChart;
  }

  getOffsetForDrawingAtPoint(posX: number, posY: number): MPPointF {
    let offset: MPPointF = this.getOffset();
    this.mOffset2.x = offset.x;
    this.mOffset2.y = offset.y;
    return this.mOffset2;
  }

  draw(c: CanvasRenderingContext2D, posX: number, posY: number, e: EntryOhos, highlight: Highlight) {
    let offset: MPPointF = this.getOffsetForDrawingAtPoint(posX, posY);
    c.save();

    let roundX = Number(e.getX().toFixed(1));
    let roundY = Number(e.getY().toFixed(1));
    let text: string = 'x:' + Math.round(roundX) + 'y:' + Math.round(roundY);

    let textMetrics: TextMetrics = c.measureText(text);
    let measureWidth: number = textMetrics.width;
    let measureHeight: number = textMetrics.height;
    let padding: number = 5;

    c.beginPath();
    c.fillStyle = '#bcbcbc';
    let left: number = posX + offset.x;
    let top: number = posY + offset.y;
    c.fillRect(left - measureWidth / 2 - padding, top - measureHeight - 4 * padding, measureWidth + 2 * padding, measureHeight + 3 * padding);
    if (measureWidth < 32) {
      measureWidth = 32;
    }
    if (measureHeight < 12) {
      measureHeight = 12;
    }
    c.beginPath();
    c.moveTo(left - 2 * padding, top - 2 * padding);
    c.lineTo(left, top + padding / 2);
    c.lineTo(left + 2 * padding, top - 2 * padding);
    c.fill();
    c.closePath();

    c.fillStyle = Color.Black;
    c.textAlign = 'center';
    c.font = "normal normal 14vp"
    c.fillText(text, left, top - 3 * padding);
    c.closePath();
    c.restore();
  }
}