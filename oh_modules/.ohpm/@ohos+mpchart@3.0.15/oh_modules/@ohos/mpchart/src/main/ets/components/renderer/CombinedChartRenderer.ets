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

import ChartAnimator from '../animation/ChartAnimator';
import CombinedChartModel from '../charts/CombinedChartModel';
import BarLineScatterCandleBubbleData from '../data/BarLineScatterCandleBubbleData';
import CombinedData from '../data/CombinedData';
import EntryOhos from '../data/EntryOhos';
import Highlight from '../highlight/Highlight';
import IBarLineScatterCandleBubbleDataSet from '../interfaces/datasets/IBarLineScatterCandleBubbleDataSet';
import { JArrayList } from '../utils/JArrayList';
import ViewPortHandler from '../utils/ViewPortHandler';
import BarChartRenderer from './BarChartRenderer';
import BubbleChartRenderer from './BubbleChartRenderer';
import CandleStickChartRenderer from './CandleStickChartRenderer';

import DataRenderer from './DataRenderer';
import LineChartRenderer from './LineChartRenderer';
import ScatterChartRenderer from './ScatterChartRenderer';
import WaterfallChartRenderer from './WaterfallChartRenderer';

export default class CombinedChartRenderer extends DataRenderer {
  protected mRenderers: JArrayList<DataRenderer> = new JArrayList<DataRenderer>();
  protected mChart: CombinedChartModel;

  constructor(chart: CombinedChartModel, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    this.mChart = chart;
    this.createRenderers();
  }

  /**
   * Creates the renderers needed for this combined-renderer in the required order. Also takes the DrawOrder into
   * consideration.
   */
  public createRenderers(): void {

    this.mRenderers.clear();

    let chart: CombinedChartModel = this.mChart as CombinedChartModel;
    if (chart == null) {
      return;
    }

    let orders: DrawOrder[] = chart.getDrawOrder();

    for (let index = 0; index < orders.length; index++) {
      if (!this.mAnimator || !this.mViewPortHandler) {
        break;
      }
      switch (orders[index]) {
        case DrawOrder.BAR:
          if (chart.getBarData() != null)
            this.mRenderers.add(new BarChartRenderer(chart, this.mAnimator, this.mViewPortHandler));
          break;
        case DrawOrder.BUBBLE:
          if (chart.getBubbleData() != null)
            this.mRenderers.add(new BubbleChartRenderer(chart, this.mAnimator, this.mViewPortHandler));
          break;
        case DrawOrder.LINE:
          if (chart.getLineData() != null)
            this.mRenderers.add(new LineChartRenderer(chart, this.mAnimator, this.mViewPortHandler));
          break;
        case DrawOrder.CANDLE:
          if (chart.getCandleData() != null)
            this.mRenderers.add(new CandleStickChartRenderer(chart, this.mAnimator, this.mViewPortHandler));
          break;
        case DrawOrder.SCATTER:
          if (chart.getScatterData() != null)
            this.mRenderers.add(new ScatterChartRenderer(chart, this.mAnimator, this.mViewPortHandler));
          break;
        case DrawOrder.WATERFALL:
          if (chart.getWaterfallData() != null)
            this.mRenderers.add(new WaterfallChartRenderer(chart, this.mAnimator, this.mViewPortHandler));
          break;
      }
    }
  }

  // @Override
  public initBuffers(): void {
    for (let index = 0; index < this.mRenderers.length(); index++) {
      this.mRenderers.get(index).initBuffers();
    }
  }

  // @Override
  public drawData(c: CanvasRenderingContext2D): void {
    for (let index = 0; index < this.mRenderers.length(); index++) {
      this.mRenderers.get(index).drawData(c);
    }
  }

  // @Override
  public drawValues(c: CanvasRenderingContext2D): void {
    for (let index = 0; index < this.mRenderers.length(); index++) {
      this.mRenderers.get(index).drawValues(c);
    }
  }

  // @Override
  public drawExtras(c: CanvasRenderingContext2D): void {
    for (let index = 0; index < this.mRenderers.length(); index++) {
      this.mRenderers.get(index).drawExtras(c);
    }
  }

  protected mHighlightBuffer: JArrayList<Highlight> = new JArrayList<Highlight>();

  // @Override
  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]): void {

    let chart: CombinedChartModel = this.mChart;
    if (chart == null) return;
    for (let index = 0; index < this.mRenderers.length(); index++) {
      this.mRenderers.get(index).drawExtras(c);
      let data: BarLineScatterCandleBubbleData<IBarLineScatterCandleBubbleDataSet<EntryOhos>> | null = null;

      if (this.mRenderers.get(index) instanceof WaterfallChartRenderer) {
        let chart = (this.mRenderers.get(index) as WaterfallChartRenderer).mChart;
        data = chart ? chart.getWaterfallData() : null;
      }
      else if (this.mRenderers.get(index) instanceof BarChartRenderer) {
        let chart = (this.mRenderers.get(index) as BarChartRenderer).mChart;
        data = chart ? chart.getBarData() : null;
      }
      else if (this.mRenderers.get(index) instanceof LineChartRenderer) {
        let chart = (this.mRenderers.get(index) as LineChartRenderer).mChart;
        data = chart ? chart.getLineData() : null;
      }
      else if (this.mRenderers.get(index) instanceof CandleStickChartRenderer) {
        let chart = (this.mRenderers.get(index) as CandleStickChartRenderer).mChart;
        data = chart ? chart.getCandleData() : null;
      }
      else if (this.mRenderers.get(index) instanceof ScatterChartRenderer) {
        let chart = (this.mRenderers.get(index) as ScatterChartRenderer).mChart;
        data = chart ? chart.getScatterData() : null;
      }
      else if (this.mRenderers.get(index) instanceof BubbleChartRenderer) {
        let chart = (this.mRenderers.get(index) as BubbleChartRenderer).mChart;
        data = chart ? chart.getBubbleData() : null;
      }

      let dataIndex: number = data == null ? -1
                                           : ( /*(CombinedData)*/
                                               chart.getData() as CombinedData).getAllData().indexOf(data);

      this.mHighlightBuffer.clear();
      for (let index = 0; index < indices.length; index++) {
        // for (Highlight h : indices) {
        if (indices[index].getDataIndex() == dataIndex || indices[index].getDataIndex() == -1)
          this.mHighlightBuffer.add(indices[index]);
      }

      let bufferSize = this.mHighlightBuffer.size();
      let highlightArr = new Array<Highlight>(bufferSize);
      for (let i = 0; i < bufferSize; i++) {
        highlightArr[i] = this.mHighlightBuffer.get(i);
      }
      this.mRenderers.get(index).drawHighlighted(c, highlightArr);
    }
  }

  /**
   * Returns the sub-renderer object at the specified index.
   *
   * @param index
   * @return
   */
  public getSubRenderer(index: number): DataRenderer | null {
    if (index >= this.mRenderers.size() || index < 0)
      return null;
    else
      return this.mRenderers.get(index);
  }

  /**
   * Returns all sub-renderers.
   *
   * @return
   */
  public getSubRenderers(): JArrayList<DataRenderer> {
    return this.mRenderers;
  }

  public setSubRenderers(renderers: JArrayList<DataRenderer>): void {
    this.mRenderers = renderers;
  }
}

export enum DrawOrder {
  WATERFALL, BAR, BUBBLE, LINE, CANDLE, SCATTER
}