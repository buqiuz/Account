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
import EntryOhos from '../data/EntryOhos';
import ILineScatterCandleRadarDataSet from '../interfaces/datasets/ILineScatterCandleRadarDataSet';
import Utils from '../utils/Utils';
import ViewPortHandler from '../utils/ViewPortHandler';
import BarLineScatterCandleBubbleRenderer from './BarLineScatterCandleBubbleRenderer';

export default abstract class LineScatterCandleRadarRenderer extends BarLineScatterCandleBubbleRenderer {
  constructor(animator: ChartAnimator, viewPortHandler: ViewPortHandler) {
    super(animator, viewPortHandler);
  }

  protected drawHighlightLines(c: CanvasRenderingContext2D, x: number, y: number, set: ILineScatterCandleRadarDataSet<EntryOhos>): void {
    let highLightColor = set.getHighLightColor();
    if (typeof highLightColor == 'number') {
      let stringColor = String(highLightColor.toString(16))
      this.mHighlightPaint.setColor('#' + stringColor);
    } else {
      this.mHighlightPaint.setColor(highLightColor);
    }
    this.mHighlightPaint.setStrokeWidth(set.getHighlightLineWidth());
    this.mHighlightPaint.setDashPathEffect(set.getDashPathEffectHighlight());
    Utils.resetContext2DWithoutFont(c, this.mHighlightPaint)
    if (set.isVerticalHighlightIndicatorEnabled()) {
      c.beginPath();
      // create vertical path
      // this.mHighlightLinePath = new Path2D();
      c.moveTo(x, (this.mViewPortHandler ? this.mViewPortHandler.contentTop() : 0));
      c.lineTo(x, (this.mViewPortHandler ? this.mViewPortHandler.contentBottom() : 0));
      c.stroke();
      c.closePath();
    }

    // draw horizontal highlight lines
    if (set.isHorizontalHighlightIndicatorEnabled()) {
      c.beginPath();
      // create horizontal path
      // this.mHighlightLinePath = new Path2D();
      c.moveTo((this.mViewPortHandler ? this.mViewPortHandler.contentLeft() : 0), y);
      c.lineTo((this.mViewPortHandler ? this.mViewPortHandler.contentRight() : 0), y);

      c.stroke();
      c.closePath();
    }
  }
}