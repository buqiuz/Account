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
import RadarChart from '../charts/RadarChartModel';
import ChartPixelMap from '../data/ChartPixelMap';
import Paint, { Style } from '../data/Paint';
import RadarData from '../data/RadarData';
import RadarEntry from '../data/RadarEntry';
import Highlight from '../highlight/Highlight';
import IRadarDataSet from '../interfaces/datasets/IRadarDataSet';
import ColorTemplate from '../utils/ColorTemplate';
import MPPointF from '../utils/MPPointF';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import { LineRadarRenderer } from './LineRadarRenderer';
import { ChartColor } from '../utils/ColorTemplate'

export default class RadarChartRenderer extends LineRadarRenderer {
  public mChart: RadarChart;
  /**
   * paint for drawing the web
   */
  public mWebPaint: Paint;
  protected mHighlightCirclePaint: Paint;

  constructor(chart: RadarChart, animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
    this.mChart = chart;

    this.mHighlightPaint = new Paint();
    this.mHighlightPaint.setStyle(Style.STROKE);
    this.mHighlightPaint.setStrokeWidth(2);
    this.mHighlightPaint.setColor(ChartColor.rgb(255, 187, 115));

    this.mWebPaint = new Paint();
    this.mWebPaint.setStyle(Style.STROKE);

    this.mHighlightCirclePaint = new Paint();
  }

  public getWebPaint(): Paint {
    return this.mWebPaint;
  }

  public initBuffers(): void {

  }

  public drawData(c: CanvasRenderingContext2D) {
    if (!this.mChart || !this.mChart.getData()) {
      return;
    }
    let radarData: RadarData | null = this.mChart.getData();
    if (!radarData) {
      return;
    }
    let countSet = radarData.getMaxEntryCountSet();
    if (!countSet) {
      return;
    }
    let mostEntries = countSet.getEntryCount();

    for (let i = 0; i < radarData.getDataSets().size(); i++) {
      let set = radarData.getDataSets().get(i);
      if (set.isVisible()) {
        this.drawDataSet(c, set, mostEntries);
      }
    }
  }

  protected mDrawDataSetSurfacePathBuffer: Path2D = new Path2D();

  /**
   * Draws the RadarDataSet
   *
   * @param c
   * @param dataSet
   * @param mostEntries the entry count of the dataset with the most entries
   */
  protected drawDataSet(c: CanvasRenderingContext2D, dataSet: IRadarDataSet, mostEntries: number): void {
    if (!this.mAnimator) {
      return;
    }
    let phaseX: number = this.mAnimator.getPhaseX();
    let phaseY: number = this.mAnimator.getPhaseY();

    let sliceangle: number = this.mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    let factor: number = this.mChart.getFactor() * 0.85;

    let center: MPPointF | null = this.mChart.getCenterOffsets();
    let pOut: MPPointF = MPPointF.getInstance(0, 0);
    let surface: Path2D = this.mDrawDataSetSurfacePathBuffer;
    surface = new Path2D();

    let hasMovedToPoint: boolean = false;

    for (let j = 0; j < dataSet.getEntryCount(); j++) {

      this.mRenderPaint.setColor(dataSet.getColor(j));

      let e: RadarEntry = dataSet.getEntryForIndex(j);

      if (center) {
        pOut = Utils.getPosition(
          center,
          (e.getY() - this.mChart.getYChartMin()) * factor * phaseY,
          sliceangle * j * phaseX + this.mChart.getRotationAngle(), pOut);
      }

      if (Number.isNaN(pOut.x))
        continue;

      if (!hasMovedToPoint) {
        surface.moveTo(pOut.x, pOut.y);
        hasMovedToPoint = true;
      } else
        surface.lineTo(pOut.x, pOut.y);
    }

    if (dataSet.getEntryCount() > mostEntries && center) {
      // if this is not the largest set, draw a line to the center before closing
      surface.lineTo(center.x, center.y);
    }
    surface.closePath();

    // surface.close();

    if (dataSet.isDrawFilledEnabled()) {
      this.drawFilledPathWithAlpha(c, surface, dataSet.getFillColor(), dataSet.getFillAlpha());
    }

    this.mRenderPaint.setStrokeWidth(dataSet.getLineWidth());
    this.mRenderPaint.setStyle(Style.STROKE);


    // draw the line (only if filled is disabled or alpha is below 255)
    if (!dataSet.isDrawFilledEnabled() || dataSet.getFillAlpha() < 255) {
      Utils.resetContext2DWithoutFont(c, this.mRenderPaint);
      c.beginPath();
      c.stroke(surface);
      c.closePath();
    }

    if (center) {
      MPPointF.recycleInstance(center);
    }
    MPPointF.recycleInstance(pOut);
  }

  public drawValues(c: CanvasRenderingContext2D) {
    if (!this.mChart || !this.mChart.getData() || !this.mAnimator) {
      return;
    }
    const phaseX = this.mAnimator.getPhaseX();
    const phaseY = this.mAnimator.getPhaseY();

    const sliceangle = this.mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    const factor = this.mChart.getFactor() * 0.85;

    const center = this.mChart.getCenterOffsets();
    let pOut = MPPointF.getInstance(0, 0);
    let pIcon = MPPointF.getInstance(0, 0);

    const yoffset = Utils.handleDataValues(5);

    for (let i = 0; i < this.mChart!.getData()!.getDataSetCount(); i++) {
      const dataSet: IRadarDataSet | null = this.mChart!.getData()!.getDataSetByIndex(i);

      if (!dataSet || !this.shouldDrawValues(dataSet)) continue;

      // apply the text-styling defined by the DataSet
      this.applyValueTextStyle(dataSet);

      const iconsOffset = MPPointF.getInstance(undefined, undefined, dataSet.getIconsOffset());
      iconsOffset.x = Utils.handleDataValues(iconsOffset.x);
      iconsOffset.y = Utils.handleDataValues(iconsOffset.y);

      for (let j = 0; j < dataSet.getEntryCount(); j++) {
        const entry: RadarEntry = dataSet.getEntryForIndex(j);

        if (center) {
          pOut = Utils.getPosition(
            center,
            (entry.getY() - this.mChart.getYChartMin()) * factor * phaseY,
            sliceangle * j * phaseX + this.mChart.getRotationAngle(),
            pOut
          );
        }

        let formatter = dataSet.getValueFormatter();
        if (dataSet.isDrawValuesEnabled() && formatter) {
          this.drawValue(
            c,
            formatter,
            entry.getY(),
            entry,
            i,
            pOut.x,
            pOut.y - yoffset,
            dataSet.getValueTextColor(j)
          );
        }

        if (entry.getIcon() != null && dataSet.isDrawIconsEnabled()) {
          const icon: ChartPixelMap | null = entry.getIcon();

          if (pIcon && center) {
            pIcon = Utils.getPosition(
              center,
              entry.getY() * factor * phaseY + iconsOffset.y,
              sliceangle * j * phaseX + this.mChart.getRotationAngle(),
              pIcon
            );
          }

          //noinspection SuspiciousNameCombination
          pIcon.y += iconsOffset.x;

          if (icon) {
            Utils.drawImage(
              c,
              icon,
              Math.floor(pIcon.x),
              Math.floor(pIcon.y),
              icon.getWidth(),
              icon.getHeight());
          }
        }
      }

      MPPointF.recycleInstance(iconsOffset);
    }

    if (center) {
      MPPointF.recycleInstance(center);
    }
    MPPointF.recycleInstance(pOut);
    MPPointF.recycleInstance(pIcon);
  }

  public drawExtras(c: CanvasRenderingContext2D) {
    this.drawWeb(c);
  }

  protected drawWeb(c: CanvasRenderingContext2D) {
    if (this.mChart == null || this.mChart.getData() == null) {
      return;
    }
    let sliceangle: number = this.mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    let factor: number = this.mChart.getFactor() * 0.85;
    let rotationangle = this.mChart.getRotationAngle();

    let center: MPPointF | null = this.mChart.getCenterOffsets();

    // draw the web lines that come from the center
    this.mWebPaint.setStrokeWidth(this.mChart.getWebLineWidth());
    this.mWebPaint.setColor(this.mChart.getWebColor());
    this.mWebPaint.setGlobalAlpha(this.mChart.getWebAlpha() / 255);

    const xIncrements: number = 1 + this.mChart.getSkipWebLineCount();
    let maxCountEntrySet = this.mChart!.getData()!.getMaxEntryCountSet();

    c.save();
    if (maxCountEntrySet) {
      let maxEntryCount: number = maxCountEntrySet.getEntryCount();

      let p: MPPointF = MPPointF.getInstance(0, 0);
      for (let i = 0; i < maxEntryCount; i += xIncrements) {
        if (center) {
          p = Utils.getPosition(
            center,
            this.mChart.getYRange() * factor,
            sliceangle * i + rotationangle,
            p);
          Utils.resetContext2DWithoutFont(c, this.mWebPaint);
          c.beginPath();
          c.moveTo(center.x, center.y);
          c.lineTo(p.x, p.y);
          c.stroke();
          c.closePath();
        }
      }
      MPPointF.recycleInstance(p);
    }

    // draw the inner-web
    this.mWebPaint.setStrokeWidth(this.mChart.getWebLineWidthInner());
    this.mWebPaint.setColor(this.mChart.getWebColorInner());
    this.mWebPaint.setGlobalAlpha(this.mChart.getWebAlpha() / 255);
    let yAxis = this.mChart.getYAxis()
    if (yAxis) {
      let labelCount = yAxis.mEntryCount;

      let p1out: MPPointF = MPPointF.getInstance(0, 0);
      let p2out: MPPointF = MPPointF.getInstance(0, 0);
      for (let j = 0; j < labelCount; j++) {
        for (let i = 0; i < this.mChart!.getData()!.getEntryCount(); i++) {

          let r: number = (yAxis.mEntries[j] - this.mChart.getYChartMin()) * factor;
          if (center) {
            p1out = Utils.getPosition(center, r, sliceangle * i + rotationangle, p1out);
            p2out = Utils.getPosition(center, r, sliceangle * (i + 1) + rotationangle, p2out);
          }
          Utils.resetContext2DWithoutFont(c, this.mWebPaint);
          c.beginPath();
          c.moveTo(p1out.x, p1out.y);
          c.lineTo(p2out.x, p2out.y);
          c.stroke();
          c.closePath();
        }
      }
      MPPointF.recycleInstance(p1out);
      MPPointF.recycleInstance(p2out);
    }
    c.restore();
  }


  public drawHighlighted(c: CanvasRenderingContext2D, indices: Highlight[]) {
    if (!this.mAnimator) {
      return;
    }
    let sliceangle: number = this.mChart.getSliceAngle();

    // calculate the factor that is needed for transforming the value to
    // pixels
    let factor: number = this.mChart.getFactor() * 0.85;

    let center: MPPointF | null = this.mChart.getCenterOffsets();
    let pOut: MPPointF = MPPointF.getInstance(0, 0);

    let radarData: RadarData | null = this.mChart.getData();
    if (radarData) {
      for (let high of indices) {
        let set: IRadarDataSet | null = radarData.getDataSetByIndex(high.getDataSetIndex());

        if (set == null || !set.isHighlightEnabled())
          continue;

        let e: RadarEntry | null = set.getEntryForIndex(Math.floor(high.getX()));
        if (!e || !this.isInBoundsX(e, set)) {
          continue;
        }

        let y: number = (e.getY() - this.mChart.getYChartMin());
        if (center) {
          pOut = Utils.getPosition(center,
            y * factor * this.mAnimator.getPhaseY(),
            sliceangle * high.getX() * this.mAnimator.getPhaseX() + this.mChart.getRotationAngle(),
            pOut);
        }

        high.setDraw(pOut.x, pOut.y);

        this.drawHighlightLines(c, pOut.x, pOut.y, set);

        if (set.isDrawHighlightCircleEnabled()) {

          if (!Number.isNaN(pOut.x) && !Number.isNaN(pOut.y)) {

            let strokeColor: number = set.getHighlightCircleStrokeColor();
            if (strokeColor == ColorTemplate.COLOR_NONE) {
              strokeColor = set.getColor(0);
            }

            if (set.getHighlightCircleStrokeAlpha() < 255) {
              strokeColor = ColorTemplate.colorWithAlpha(strokeColor, set.getHighlightCircleStrokeAlpha());
            }

            this.drawHighlightCircle(c,
              pOut,
              set.getHighlightCircleInnerRadius(),
              set.getHighlightCircleOuterRadius(),
              set.getHighlightCircleFillColor(),
              strokeColor,
              set.getHighlightCircleStrokeWidth());
          }
        }
      }
    }
    if (center) {
      MPPointF.recycleInstance(center);
    }
    MPPointF.recycleInstance(pOut);
  }

  protected mDrawHighlightCirclePathBuffer: Path2D = new Path2D();

  public drawHighlightCircle(
    c: CanvasRenderingContext2D,
    point: MPPointF,
    innerRadius: number,
    outerRadius: number,
    fillColor: number,
    strokeColor: number,
    strokeWidth: number
  ): void {
    c.save();

    outerRadius = Utils.handleDataValues(outerRadius);
    innerRadius = Utils.handleDataValues(innerRadius);

    if (fillColor !== ColorTemplate.COLOR_NONE) {
      let p: Path2D = this.mDrawHighlightCirclePathBuffer;
      p = new Path2D();
      // p.reset();
      // p.addCircle(point.x, point.y, outerRadius, Path.Direction.CW);
      c.beginPath();
      p.arc(point.x, point.y, outerRadius, 0, 2 * Math.PI, false);
      if (innerRadius > 0) {
        // p.addCircle(point.x, point.y, innerRadius, Path.Direction.CCW);
        p.arc(point.x, point.y, innerRadius, 0, 2 * Math.PI, true);
      }
      this.mHighlightCirclePaint.setColor(fillColor);
      this.mHighlightCirclePaint.setStyle(Style.FILL);
      Utils.resetContext2DWithoutFont(c, this.mHighlightCirclePaint);
      // c.drawPath(p, this.mHighlightCirclePaint);
      c.closePath();
      c.fill(p);
    }

    if (strokeColor !== ColorTemplate.COLOR_NONE) {
      this.mHighlightCirclePaint.setColor(strokeColor);
      this.mHighlightCirclePaint.setStyle(Style.STROKE);
      this.mHighlightCirclePaint.setStrokeWidth(Utils.handleDataValues(strokeWidth));
      Utils.resetContext2DWithoutFont(c, this.mHighlightCirclePaint);
      c.beginPath();
      // c.drawCircle(point.x, point.y, outerRadius, this.mHighlightCirclePaint);
      c.arc(point.x, point.y, outerRadius, 0, 2 * Math.PI,)
      c.stroke();
      c.closePath();
    }

    c.restore();
  }
}
