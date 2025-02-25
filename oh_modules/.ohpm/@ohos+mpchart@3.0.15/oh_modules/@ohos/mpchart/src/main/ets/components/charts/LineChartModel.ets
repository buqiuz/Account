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
import EntryOhos from '../data/EntryOhos';

import LineData from '../data/LineData';
import Highlight from '../highlight/Highlight';
import LineDataProvider from '../interfaces/dataprovider/LineDataProvider';
import IDataSet from '../interfaces/datasets/IDataSet';
import LineChartRenderer from '../renderer/LineChartRenderer';
import CanvasUtil from '../utils/CanvasUtil';
import BarLineChartBaseModel from './BarLineChartBaseModel';
import { LastGesture } from './ChartModel';

export default class LineChartModel extends BarLineChartBaseModel<LineData> implements LineDataProvider {
  public context2d: CanvasRenderingContext2D | null = null;
  public highlightContext2D: CanvasRenderingContext2D | null = null;

  constructor() {
    super();
    this.init();
  }

  public invalidate() {
    if (this.context2d) {
      this.invalidateHighlight();
      this.onDraw(this.context2d);
    }
  }

  public invalidateHighlight() {
    if (this.highlightContext2D) {
      this.clearHighlight();
      if (this.mIndicesToHighlight) {
        this.highlightContext2D.save();
        if (this.isClipDataToContentEnabled()) {
          // make sure the data cannot be drawn outside the content-rect
          let rect = this.mViewPortHandler.getContentRect();
          this.highlightContext2D.beginPath();
          this.highlightContext2D.rect(rect.left, rect.top, rect.width(), rect.height());
          this.highlightContext2D.closePath();
          this.highlightContext2D.clip();
        }

        this.mRenderer?.drawHighlighted(this.highlightContext2D, this.mIndicesToHighlight, true);
        this.drawMarkers(this.highlightContext2D, true);
        this.drawLongPressMarkers(this.highlightContext2D, true);
        this.highlightContext2D.restore();
      }
    }
  }

  /**
   * draws all MarkerViews on the highlighted positions
   */
  protected drawMarkers(c: CanvasRenderingContext2D, isDraw?: boolean): void {
    if (this.mLastGesture != LastGesture.SINGLE_TAP || !isDraw) {
      return;
    }

    // if there is no marker view or drawing marker is disabled
    if (this.mMarker == null || !this.isDrawMarkersEnabled() || !this.valuesToHighlight())
      return;

    if (this.mIndicesToHighlight && this.mData) {
      for (let i = 0; i < this.mIndicesToHighlight.length; i++) {

        let highlight: Highlight = this.mIndicesToHighlight[i];

        let dataSet: IDataSet<EntryOhos> | null = this.mData.getDataSetByIndex(highlight.getDataSetIndex()) as IDataSet<EntryOhos>;

        if (dataSet) {
          let e: EntryOhos | null = this.mData.getEntryForHighlight(this.mIndicesToHighlight[i]);
          if (!e) {
            continue;
          }
          let entryIndex: number = dataSet.getEntryIndexByEntry(e);
          // make sure entry not null
          if (e == null || this.mAnimator == null || entryIndex > dataSet.getEntryCount() * this.mAnimator.getPhaseX())
            continue;

          let pos: number[] = this.getMarkerPosition(highlight);

          // check bounds
          if (!this.mViewPortHandler.isInBounds(pos[0], pos[1]))
            continue;

          if (this.mMarker) {
            // callbacks to update the content
            this.mMarker.draw(c, pos[0], pos[1], e, highlight);
          }
        }
      }
    }
  }

  protected drawLongPressMarkers(c: CanvasRenderingContext2D, isDraw?: boolean): void {
    if (this.mLastGesture != LastGesture.LONG_PRESS || !isDraw) {
      return;
    }
    if (this.mLongPressMarker == null || !this.isDrawLongPressMarkersEnabled() || !this.valuesToHighlight()) {
      return;
    }

    if (this.mIndicesToHighlight && this.mData) {
      for (let i = 0; i < this.mIndicesToHighlight.length; i++) {
        console.log("abc123 LineChartModel drawLongPressMarkers");
        let highlight: Highlight = this.mIndicesToHighlight[i];
        let dataSet: IDataSet<EntryOhos> | null = this.mData.getDataSetByIndex(highlight.getDataSetIndex()) as IDataSet<EntryOhos>;
        if (dataSet) {
          let e: EntryOhos | null = this.mData.getEntryForHighlight(this.mIndicesToHighlight[i]);
          if (!e) {
            continue;
          }
          let entryIndex: number = dataSet.getEntryIndexByEntry(e);
          if (e == null || this.mAnimator == null || entryIndex > dataSet.getEntryCount() * this.mAnimator.getPhaseX()) {
            continue;
          }
          let pos: number[] = this.getMarkerPosition(highlight);
          if (!this.mViewPortHandler.isInBounds(pos[0], pos[1])) {
            continue;
          }
          if (this.mLongPressMarker) {
            this.mLongPressMarker.draw(c, pos[0], pos[1], e, highlight);
          }
        }
      }
    }
  }

  public clearHighlight() {
    CanvasUtil.clearCanvas(this.highlightContext2D);
  }

  public setContext2D(context2d: CanvasRenderingContext2D) {
    this.context2d = context2d;
  }

  public setHighlightContext2D(context2D: CanvasRenderingContext2D) {
    this.highlightContext2D = context2D;
  }

  public onChartSizeChanged(newWidth: number, newHeight: number, oldWidth: number, oldHeight: number) {
    super.onSizeChanged(newWidth, newHeight, oldWidth, oldHeight);
  }

  public onDraw(c: CanvasRenderingContext2D): void {
    super.onDraw(c);
  }

  protected init(): void {
    super.init();

    this.mRenderer = new LineChartRenderer(this, this.mAnimator!, this.mViewPortHandler);
  }


  public getLineData(): LineData | null {
    return this.mData;
  }
}