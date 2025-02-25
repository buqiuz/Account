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
import CandleData from '../data/CandleData';
import CandleEntry from '../data/CandleEntry';
import ChartPixelMap from '../data/ChartPixelMap';
import { Style } from '../data/Paint';
import Highlight from '../highlight/Highlight';
import CandleDataProvider from '../interfaces/dataprovider/CandleDataProvider';
import ICandleDataSet from '../interfaces/datasets/ICandleDataSet';
import { ColorTemplate } from '../utils/ColorTemplate';
import { JArrayList } from '../utils/JArrayList';
import MPPointD from '../utils/MPPointD';
import MPPointF from '../utils/MPPointF';
import Transformer from '../utils/Transformer';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import LineScatterCandleRadarRenderer from './LineScatterCandleRadarRenderer';

export default class CandleStickChartRenderer extends LineScatterCandleRadarRenderer {
  public mChart: CandleDataProvider | null = null;
  private mShadowBuffers: number[] = new Array<number>(8);
  private mBodyBuffers: number[] = new Array<number>(4);
  private mRangeBuffers: number[] = new Array<number>(4);
  private mOpenBuffers: number[] = new Array<number>(4);
  private mCloseBuffers: number[] = new Array<number>(4);

  constructor(chart: CandleDataProvider, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler)
    this.mChart = chart;
  }

  public initBuffers() {
  }

  public drawData(c: CanvasRenderingContext2D): void {
    if (!this.mChart) {
      return;
    }
    let candleData: CandleData | null = this.mChart.getCandleData();
    if (candleData) {
      let dataSets = candleData.getDataSets();

      if (dataSets) {
        for (let i = 0; i < dataSets.size(); i++) {
          let set: ICandleDataSet = dataSets.get(i);
          if (set && set.isVisible()) {
            this.drawDataSet(c, set);
          }
        }
      }
    }
  }

  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: ICandleDataSet): void {
    if (!this.mChart) {
      return;
    }

    let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());

    let phaseY: number = this.mAnimator ? this.mAnimator.getPhaseY() : 1;
    let barSpace: number = dataSet.getBarSpace();
    let showCandleBar: boolean = dataSet.getShowCandleBar();

    if (this.mXBounds) {
      this.mXBounds.set(this.mChart, dataSet);

      this.mRenderPaint.setStrokeWidth(dataSet.getShadowWidth());
      // LogUtil.log('-------------------------dataRenderbuffers drawDataSet: ' + this.mXBounds.min + "  length: " + (this.mXBounds.range + this.mXBounds.min))
      for (let j = this.mXBounds.min; j <= this.mXBounds.range + this.mXBounds.min; j++) {
        let e: CandleEntry = dataSet.getEntryForIndex(j);
        if (!e) {
          continue;
        }
        const xPos: number = e.getX();
        const open: number = e.getOpen();
        const close: number = e.getClose();
        const high: number = e.getHigh();
        const low: number = e.getLow();

        if (showCandleBar) {
          this.mShadowBuffers[0] = xPos;
          this.mShadowBuffers[2] = xPos;
          this.mShadowBuffers[4] = xPos;
          this.mShadowBuffers[6] = xPos;

          if (open > close) {
            this.mShadowBuffers[1] = high * phaseY;
            this.mShadowBuffers[3] = open * phaseY;
            this.mShadowBuffers[5] = low * phaseY;
            this.mShadowBuffers[7] = close * phaseY;
          } else if (open < close) {
            this.mShadowBuffers[1] = high * phaseY;
            this.mShadowBuffers[3] = close * phaseY;
            this.mShadowBuffers[5] = low * phaseY;
            this.mShadowBuffers[7] = open * phaseY;
          } else {
            this.mShadowBuffers[1] = high * phaseY;
            this.mShadowBuffers[3] = open * phaseY;
            this.mShadowBuffers[5] = low * phaseY;
            this.mShadowBuffers[7] = this.mShadowBuffers[3];
          }
          if (trans) {
            trans.pointValuesToPixel(this.mShadowBuffers);
          }

          if (dataSet.getShadowColorSameAsCandle()) {
            if (open > close) {
              this.mRenderPaint.setColor(
                  dataSet.getDecreasingColor() == ColorTemplate.COLOR_NONE ?
                dataSet.getColor(j) :
                dataSet.getDecreasingColor()
              );
            } else if (open < close) {
              this.mRenderPaint.setColor(
                  dataSet.getIncreasingColor() == ColorTemplate.COLOR_NONE ?
                dataSet.getColor(j) :
                dataSet.getIncreasingColor()
              );
            } else {
              this.mRenderPaint.setColor(
                  dataSet.getNeutralColor() == ColorTemplate.COLOR_NONE ?
                dataSet.getColor(j) :
                dataSet.getNeutralColor()
              );
            }
          } else {
            this.mRenderPaint.setColor(
                dataSet.getShadowColor() == ColorTemplate.COLOR_NONE ?
              dataSet.getColor(j) :
              dataSet.getShadowColor()
            );
          }

          this.mRenderPaint.setStyle(Style.STROKE);
          Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
          c.beginPath();
          c.moveTo(this.mShadowBuffers[0], this.mShadowBuffers[1]);
          c.lineTo(this.mShadowBuffers[2], this.mShadowBuffers[3])
          c.moveTo(this.mShadowBuffers[4], this.mShadowBuffers[5]);
          c.lineTo(this.mShadowBuffers[6], this.mShadowBuffers[7])
          c.stroke();
          c.closePath();

          this.mBodyBuffers[0] = xPos - 0.5 + barSpace;
          this.mBodyBuffers[1] = close * phaseY;
          this.mBodyBuffers[2] = (xPos + 0.5 - barSpace);
          this.mBodyBuffers[3] = open * phaseY;

          if (trans) {
            trans.pointValuesToPixel(this.mBodyBuffers);
          }

          if (open > close) {

            if (dataSet.getDecreasingColor() == ColorTemplate.COLOR_NONE) {
              this.mRenderPaint.setColor(dataSet.getColor(j));
            } else {
              this.mRenderPaint.setColor(dataSet.getDecreasingColor());
            }

            this.mRenderPaint.setStyle(dataSet.getDecreasingPaintStyle());
            Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
            let paintStyle = this.mRenderPaint.getStyle();
            switch (paintStyle) {
              case Style.STROKE:
                c.strokeRect(this.mBodyBuffers[0], this.mBodyBuffers[3],
                  this.mBodyBuffers[2] - this.mBodyBuffers[0], this.mBodyBuffers[1] - this.mBodyBuffers[3]);
                break;
              case Style.FILL:
              case Style.FILL_AND_STROKE:
              default:
                c.fillRect(this.mBodyBuffers[0], this.mBodyBuffers[3],
                  this.mBodyBuffers[2] - this.mBodyBuffers[0], this.mBodyBuffers[1] - this.mBodyBuffers[3]);
                break;
            }
          } else if (open < close) {
            if (dataSet.getIncreasingColor() == ColorTemplate.COLOR_NONE) {
              this.mRenderPaint.setColor(dataSet.getColor(j));
            } else {
              this.mRenderPaint.setColor(dataSet.getIncreasingColor());
            }

            this.mRenderPaint.setStyle(dataSet.getIncreasingPaintStyle());
            Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
            let paintStyle = this.mRenderPaint.getStyle();

            switch (paintStyle) {
              case Style.STROKE:
                c.strokeRect(this.mBodyBuffers[0], this.mBodyBuffers[1],
                  this.mBodyBuffers[2] - this.mBodyBuffers[0], this.mBodyBuffers[3] - this.mBodyBuffers[1]);
                break;
              case Style.FILL:
              case Style.FILL_AND_STROKE:
              default:
                c.fillRect(this.mBodyBuffers[0], this.mBodyBuffers[1],
                  this.mBodyBuffers[2] - this.mBodyBuffers[0], this.mBodyBuffers[3] - this.mBodyBuffers[1]);
                break;
            }
          } else {
            if (dataSet.getNeutralColor() == ColorTemplate.COLOR_NONE) {
              this.mRenderPaint.setColor(dataSet.getColor(j));
            } else {
              this.mRenderPaint.setColor(dataSet.getNeutralColor());
            }
            Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
            c.moveTo(this.mBodyBuffers[0], this.mBodyBuffers[1]);
            c.lineTo(this.mBodyBuffers[2], this.mBodyBuffers[3]);
            c.stroke();
          }
        } else {
          this.mRangeBuffers[0] = xPos;
          this.mRangeBuffers[1] = high * phaseY;
          this.mRangeBuffers[2] = xPos;
          this.mRangeBuffers[3] = low * phaseY;

          this.mOpenBuffers[0] = xPos - 0.5 + barSpace;
          this.mOpenBuffers[1] = open * phaseY;
          this.mOpenBuffers[2] = xPos;
          this.mOpenBuffers[3] = open * phaseY;

          this.mCloseBuffers[0] = xPos + 0.5 - barSpace;
          this.mCloseBuffers[1] = close * phaseY;
          this.mCloseBuffers[2] = xPos;
          this.mCloseBuffers[3] = close * phaseY;

          if (trans) {
            trans.pointValuesToPixel(this.mRangeBuffers);
            trans.pointValuesToPixel(this.mOpenBuffers);
            trans.pointValuesToPixel(this.mCloseBuffers);
          }

          let barColor: number = 0;

          if (open > close) {
            barColor = dataSet.getDecreasingColor() == ColorTemplate.COLOR_NONE
              ? dataSet.getColor(j)
              : dataSet.getDecreasingColor();
          } else if (open < close) {
            barColor = dataSet.getIncreasingColor() == ColorTemplate.COLOR_NONE
              ? dataSet.getColor(j)
              : dataSet.getIncreasingColor();
          } else {
            barColor = dataSet.getNeutralColor() == ColorTemplate.COLOR_NONE
              ? dataSet.getColor(j)
              : dataSet.getNeutralColor();
          }

          this.mRenderPaint.setColor(barColor);
          Utils.resetContext2DWithoutFont(c, this.mRenderPaint)
          c.moveTo(this.mRangeBuffers[0], this.mRangeBuffers[1]);
          c.lineTo(this.mRangeBuffers[2], this.mRangeBuffers[3]);

          c.moveTo(this.mOpenBuffers[0], this.mOpenBuffers[1]);
          c.lineTo(this.mOpenBuffers[2], this.mOpenBuffers[3]);

          c.moveTo(this.mCloseBuffers[0], this.mCloseBuffers[1]);
          c.lineTo(this.mCloseBuffers[2], this.mCloseBuffers[3]);
        }
      }
    }
  }

  public drawValues(c: CanvasRenderingContext2D): void {
    if (!this.mChart) {
      return;
    }
    if (this.isDrawingValuesAllowed(this.mChart)) {
      let chartData = this.mChart.getCandleData();
      if (!chartData) {
        return;
      }

      let dataSets: JArrayList<ICandleDataSet> = chartData.getDataSets();

      for (let i = 0; i < dataSets.size(); i++) {
        let dataSet: ICandleDataSet = dataSets.get(i);

        if (!this.shouldDrawValues(dataSet) || dataSet.getEntryCount() < 1) {
          continue;
        }

        this.applyValueTextStyle(dataSet);

        let trans: Transformer | null = this.mChart.getTransformer(dataSet.getAxisDependency());
        if (this.mXBounds) {
          this.mXBounds.set(this.mChart, dataSet);
          let positions: number[] = [];
          if (trans) {
            positions = trans.generateTransformedValuesCandle(
              dataSet, (this.mAnimator ? this.mAnimator.getPhaseX() : 1), (this.mAnimator ? this.mAnimator.getPhaseY() : 1), this.mXBounds.min, this.mXBounds.max);
          }

          let yOffset: number = Utils.handleDataValues(5.0);

          let iconsOffset: MPPointF = MPPointF.getInstance(undefined, undefined, dataSet.getIconsOffset());
          iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
          iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

          for (let j = 0; j < positions.length; j += 2) {
            let x: number = positions[j];
            let y: number = positions[j + 1];

            if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsRight(x)) {
              break;
            }

            if (!this.mViewPortHandler || !this.mViewPortHandler.isInBoundsLeft(x) || !this.mViewPortHandler.isInBoundsY(y)) {
              continue;
            }

            let entry: CandleEntry = dataSet.getEntryForIndex(j / 2 + this.mXBounds.min);

            if (dataSet.isDrawValuesEnabled()) {
              this.drawValue(
                c,
                dataSet.getValueFormatter() !,
                entry.getHigh(),
                entry,
                i,
                x,
                y - yOffset,
                dataSet.getValueTextColor(j / 2))
            }
            if (entry.getIcon != null && dataSet.isDrawIconsEnabled()) {
              let icon: ChartPixelMap | null = entry.getIcon();
              if (icon) {
                Utils.drawImage(
                  c,
                  icon,
                  Number(x + iconsOffset.x),
                  Number(y + iconsOffset.y),
                  icon.getWidth(),
                  icon.getHeight());
              }
            }
          }
          MPPointF.recycleInstance(iconsOffset);
        }
      }
    }
  }

  public drawExtras(c: CanvasRenderingContext2D) {

  }

  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]) {
    if (!this.mChart) {
      return;
    }
    let candleData: CandleData | null = this.mChart.getCandleData();
    if (!candleData) {
      return;
    }

    for (let i = 0; i < indices.length; i++) {
      let high = indices[i];

      let set: ICandleDataSet | null = candleData.getDataSetByIndex(high.getDataSetIndex());

      if (set == null || !set.isHighlightEnabled()) {
        continue;
      }
      let e: CandleEntry | null = set.getEntryForXValue(high.getX(), high.getY());
      if (!e) {
        continue;
      }

      if (!this.isInBoundsX(e, set)) {
        continue;
      }
      let lowValue: number = e.getLow() * (this.mAnimator ? this.mAnimator.getPhaseY() : 1);
      let highValue: number = e.getHigh() * (this.mAnimator ? this.mAnimator.getPhaseY() : 1);

      let y: number = (lowValue + highValue) / 2.0;
      let transformer: Transformer | null = this.mChart.getTransformer(set.getAxisDependency());
      let pix: MPPointD = MPPointD.getInstance(0, 0);
      if (transformer) {
        pix = transformer.getPixelForValues(e.getX(), y);
      }
      high.setDraw(Number(pix.x), Number(pix.y));
      this.drawHighlightLines(c, Number(pix.x), Number(pix.y), set);
    }
  }
}