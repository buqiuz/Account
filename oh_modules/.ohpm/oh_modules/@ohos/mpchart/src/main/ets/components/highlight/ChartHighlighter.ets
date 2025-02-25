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

import { AxisDependency } from '../components/YAxis';
import BarLineScatterCandleBubbleData from '../data/BarLineScatterCandleBubbleData';
import { Rounding } from '../data/DataSet';
import EntryOhos from '../data/EntryOhos';
import BarLineScatterCandleBubbleDataProvider from '../interfaces/dataprovider/BarLineScatterCandleBubbleDataProvider';
import IDataSet from '../interfaces/datasets/IDataSet';
import MPPointD from '../utils/MPPointD';
import { JArrayList } from '../utils/JArrayList';
import Highlight from './Highlight';
import IHighlighter from './IHighlighter';
import IBarLineScatterCandleBubbleDataSet from '../interfaces/datasets/IBarLineScatterCandleBubbleDataSet';
import Transformer from '../utils/Transformer';

export default class ChartHighlighter<T extends BarLineScatterCandleBubbleDataProvider> implements IHighlighter {
  /**
   * instance of the data-provider
   */
  protected mChart: T;
  /**
   * buffer for storing previously highlighted values
   */
  protected mHighlightBuffer: JArrayList<Highlight> = new JArrayList<Highlight>();

  constructor(chart: T) {
    this.mChart = chart;
  }

  //    @Override
  public getHighlight(x: number, y: number): Highlight | null {

    let pos: MPPointD = this.getValsForTouch(x, y);
    let xVal: number = pos.x;
    MPPointD.recycleInstance(pos);

    let high: Highlight | null = this.getHighlightForX(xVal, x, y);
    return high;
  }

  /**
   * Returns a recyclable MPPointD instance.
   * Returns the corresponding xPos for a given touch-position in pixels.
   *
   * @param x
   * @param y
   * @return
   */
  protected getValsForTouch(x: number, y: number): MPPointD {

    // take any transformer to determine the x-axis value
    let transformer: Transformer | null = this.mChart.getTransformer(AxisDependency.LEFT);
    let pos: MPPointD = MPPointD.getInstance(0, 0);
    if (transformer) {
      pos = transformer.getValuesByTouchPoint(x, y);
    }
    return pos;
  }

  /**
   * Returns the corresponding Highlight for a given xVal and x- and y-touch position in pixels.
   *
   * @param xVal
   * @param x
   * @param y
   * @return
   */
  protected getHighlightForX(xVal: number, x: number, y: number): Highlight | null {

    let closestValues: JArrayList<Highlight> | null = this.getHighlightsAtXValue(xVal, x, y);

    if (!closestValues || closestValues.isEmpty()) {
      return null;
    }

    let leftAxisMinDist: number = this.getMinimumDistance(closestValues, y, AxisDependency.LEFT);
    let rightAxisMinDist: number = this.getMinimumDistance(closestValues, y, AxisDependency.RIGHT);

    let axis: AxisDependency = AxisDependency.LEFT;
    if (leftAxisMinDist == Number.MAX_VALUE) {
      axis = AxisDependency.RIGHT;
    } else if (rightAxisMinDist == Number.MAX_VALUE) {
      axis = AxisDependency.LEFT;
    } else {
      axis = leftAxisMinDist < rightAxisMinDist ? AxisDependency.LEFT : AxisDependency.RIGHT;
    }


    let detail: Highlight | null = this.getClosestHighlightByPixel(closestValues, x, y, axis, this.mChart.getMaxHighlightDistance());

    return detail;
  }

  /**
   * Returns the minimum distance from a touch value (in pixels) to the
   * closest value (in pixels) that is displayed in the chart.
   *
   * @param closestValues
   * @param pos
   * @param axis
   * @return
   */
  protected getMinimumDistance(closestValues: JArrayList<Highlight>, pos: number, axis: AxisDependency): number {

    let distance: number = Number.MAX_VALUE;

    for (let i: number = 0; i < closestValues.size(); i++) {

      let high: Highlight | null = closestValues.get(i);

      if (high && high.getAxis() == axis) {

        let tempDistance: number = Math.abs(this.getHighlightPos(high) - pos);
        if (tempDistance < distance) {
          distance = tempDistance;
        }
      }
    }

    return distance;
  }

  protected getHighlightPos(h: Highlight): number {
    return h.getYPx();
  }

  /**
   * Returns a list of Highlight objects representing the entries closest to the given xVal.
   * The returned list contains two objects per DataSet (closest rounding up, closest rounding down).
   *
   * @param xVal the transformed x-value of the x-touch position
   * @param x    touch position
   * @param y    touch position
   * @return
   */
  protected getHighlightsAtXValue(xVal: number, x: number, y: number): JArrayList<Highlight> | null {

    this.mHighlightBuffer.clear();

    let data: BarLineScatterCandleBubbleData<IBarLineScatterCandleBubbleDataSet<EntryOhos>> | null = this.getData();

    if (data == null)
      return this.mHighlightBuffer;

    for (let i: number = 0, dataSetCount = data.getDataSetCount(); i < dataSetCount; i++) {

      let dataSet: IDataSet<EntryOhos> | null = data.getDataSetByIndex(i);

      // don't include DataSets that cannot be highlighted
      if (dataSet && !dataSet.isHighlightEnabled())
        continue;

      if (dataSet) {
        this.mHighlightBuffer.addAll(this.buildHighlights(dataSet, i, xVal, Rounding.CLOSEST));
      }
    }

    return this.mHighlightBuffer;
  }

  /**
   * An array of `Highlight` objects corresponding to the selected xValue and dataSetIndex.
   *
   * @param set
   * @param dataSetIndex
   * @param xVal
   * @param rounding
   * @return
   */
  protected buildHighlights(set: IDataSet<EntryOhos>, dataSetIndex: number, xVal: number, rounding: Rounding): JArrayList<Highlight> {

    let highlights: JArrayList<Highlight> = new JArrayList<Highlight>();

    //noinspection unchecked
    let entries: JArrayList<EntryOhos> | null = set.getEntriesForXValue(xVal);
    if (entries) {
      if (entries.size() == 0) {
        // Try to find closest x-value and take all entries for that x-value
        let closest: EntryOhos | null = set.getEntryForXValue(xVal, Number.NaN, rounding);
        if (closest != null) {
          //noinspection unchecked
          entries = set.getEntriesForXValue(closest.getX());
        }
      }

      if (entries) {
        if (entries.size() == 0)
          return highlights;

        for (let e of entries.dataSource) {
          let axisObj: AxisDependency | null = set.getAxisDependency();
          if (axisObj !== null) {
            let transformer: Transformer | null = this.mChart.getTransformer(axisObj);
            let pixels: MPPointD = MPPointD.getInstance(0, 0);
            if (transformer) {
              pixels = transformer.getPixelForValues(e.getX(), e.getY());
            }

            highlights.add(new Highlight(
              e.getX(), e.getY(),
              dataSetIndex, 0, 0, pixels.x, pixels.y, axisObj));
          }

        }
      }
    }
    return highlights;
  }

  /**
   * Returns the Highlight of the DataSet that contains the closest value on the
   * y-axis.
   *
   * @param closestValues        contains two Highlight objects per DataSet closest to the selected x-position (determined by
   *                             rounding up an down)
   * @param x
   * @param y
   * @param axis                 the closest axis
   * @param minSelectionDistance
   * @return
   */
  public getClosestHighlightByPixel(closestValues: JArrayList<Highlight>, x: number, y: number,
                                    axis: AxisDependency, minSelectionDistance: number): Highlight | null {

    let closest: Highlight | null = null;
    let distance: number = minSelectionDistance;

    for (let i: number = 0; i < closestValues.size(); i++) {

      let high: Highlight = closestValues.get(i);

      if (axis == null || high.getAxis() == axis) {

        let cDistance: number = 0;
        if (this.mChart.getData()?.isHighlightByXDistance()) {
          cDistance = Math.abs(x - high.getXPx());
        } else {
          cDistance = this.getDistance(x, y, high.getXPx(), high.getYPx());
        }

        if (cDistance < distance) {
          closest = high;
          distance = cDistance;
        }
      }
    }

    return closest;
  }

  /**
   * Calculates the distance between the two given points.
   *
   * @param x1
   * @param y1
   * @param x2
   * @param y2
   * @return
   */
  protected getDistance(x1: number, y1: number, x2: number, y2: number): number {
    //return Math.abs(y1 - y2);
    //return Math.abs(x1 - x2);
    return Math.hypot(x1 - x2, y1 - y2);
  }

  protected getData(): BarLineScatterCandleBubbleData<IBarLineScatterCandleBubbleDataSet<EntryOhos>> | null {
    return this.mChart.getData();
  }
}