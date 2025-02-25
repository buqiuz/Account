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

import { JArrayList } from '../utils/JArrayList';

class ChartColor {
  build() {
  }

  public static argb(a: number, r: number, g: number, b: number): number {
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  public static rgb(r: number, g: number, b: number): number {
    return (r << 16) | (g << 8) | b;
  }

  public static alpha(color: number): number {
    return (color >> 24) & 0xff;
  }

  public static red(color: number): number {
    return (color >> 16) & 0xff;
  }

  public static green(color: number): number {
    return (color >> 8) & 0xff;
  }

  public static blue(color: number): number {
    return (color) & 0xff;
  }

  public static RGBToHSV(r: number, g: number, b: number, hsv: number[]): void {
    let h: number = 0, s: number = 0, v: number = 0;
    let arr: number[] = [r, g, b];
    arr.sort((a: number, b: number) => {
      return a - b;
    })
    let max: number = arr[2]
    let min: number = arr[0];
    v = max / 255;
    if (max === 0) {
      s = 0;
    } else {
      s = 1 - (min / max);
    }
    if (max === min) {
      h = 0; //事实上，max===min的时候，h无论为多少都无所谓
    } else if (max === r && g >= b) {
      h = 60 * ((g - b) / (max - min)) + 0;
    } else if (max === r && g < b) {
      h = 60 * ((g - b) / (max - min)) + 360
    } else if (max === g) {
      h = 60 * ((b - r) / (max - min)) + 120
    } else if (max === b) {
      h = 60 * ((r - g) / (max - min)) + 240
    }
    h = Math.floor(h);
    s = Math.floor(s * 100);
    v = Math.floor(v * 100);
    hsv.splice(0, hsv.length);
    hsv.push(h, s, v)
  }

  public static HSVToColor(alpha: number, arr: number[]): number {
    let h = arr[0], s = arr[1], v = arr[2];
    s = s / 100;
    v = v / 100;
    let r = 0, g = 0, b = 0;
    let i = Math.floor((h / 60) % 6);
    let f = h / 60 - i;
    let p = v * (1 - s);
    let q = v * (1 - f * s);
    let t = v * (1 - (1 - f) * s);
    switch (i) {
      case 0:
        r = v;
        g = t;
        b = p;
        break;
      case 1:
        r = q;
        g = v;
        b = p;
        break;
      case 2:
        r = p;
        g = v;
        b = t;
        break;
      case 3:
        r = p;
        g = q;
        b = v;
        break;
      case 4:
        r = t;
        g = p;
        b = v;
        break;
      case 5:
        r = v;
        g = p;
        b = q;
        break;
      default:
        break;
    }
    r = Math.floor(r * alpha)
    g = Math.floor(g * alpha)
    b = Math.floor(b * alpha)
    return ChartColor.rgb(r, g, b)
  }
}

/**
 * Class that holds predefined color integer arrays (e.g.
 * ColorTemplate.VORDIPLOM_COLORS) and convenience methods for loading colors
 * from resources.
 *
 *
 */
class ColorTemplate {
  build() {
  }

  /**
   * an "invalid" color that indicates that no color is set
   */
  public static COLOR_NONE: number = 0x00112233;
  /**
   * this "color" is used for the Legend creation and indicates that the next
   * form should be skipped
   */
  public static COLOR_SKIP: number = 0x00112234;
  public static DKGRAY: number = 0xFF444444;
  /**
   * THE COLOR THEMES ARE PREDEFINED (predefined color integer arrays), FEEL
   * FREE TO CREATE YOUR OWN WITH AS MANY DIFFERENT COLORS AS YOU WANT
   */
  public static LIBERTY_COLORS: number[] = [
  ChartColor.rgb(207, 248, 246), ChartColor.rgb(148, 212, 212), ChartColor.rgb(136, 180, 187),
  ChartColor.rgb(118, 174, 175), ChartColor.rgb(42, 109, 130)
  ];
  public static JOYFUL_COLORS: number[] = [
  ChartColor.rgb(217, 80, 138), ChartColor.rgb(254, 149, 7), ChartColor.rgb(254, 247, 120),
  ChartColor.rgb(106, 167, 134), ChartColor.rgb(53, 194, 209)
  ];
  public static PASTEL_COLORS: number[] = [
  ChartColor.rgb(64, 89, 128), ChartColor.rgb(149, 165, 124), ChartColor.rgb(217, 184, 162),
  ChartColor.rgb(191, 134, 134), ChartColor.rgb(179, 48, 80)
  ];
  public static COLORFUL_COLORS: number[] = [
  ChartColor.rgb(193, 37, 82), ChartColor.rgb(255, 102, 0), ChartColor.rgb(245, 199, 0),
  ChartColor.rgb(106, 150, 31), ChartColor.rgb(179, 100, 53)
  ];
  public static VORDIPLOM_COLORS: number[] = [
  ChartColor.rgb(192, 255, 140), ChartColor.rgb(255, 247, 140), ChartColor.rgb(255, 208, 140),
  ChartColor.rgb(140, 234, 255), ChartColor.rgb(255, 140, 157)
  ];
  public static MATERIAL_COLORS: number[] = [
    0x2ecc71, 0xf1c40f, 0xe74c3c, 0x3498db
  ];

  /**
   * Converts the given hex-color-string to rgb.
   *
   * @param {string} hex - 要转换的十六进制颜色代码（例如，"#336699"）,或者带透明度的颜色代码（例如，”#99336699“）
   * @return {number} - 表示颜色的RGB值, 例如 0x336699 或者 0x99336699
   */
  public static rgb(hex: string): number {
    return Number("0x" + hex.replace("#", ""));
  }

  /**
   *
   * @return
   */
  public static getHoloBlue(): number {
    return ChartColor.rgb(51, 181, 229)
  }

  /**
   * Sets the alpha component of the given color.
   *
   * @param color
   * @param alpha 0 - 255
   * @return
   */
  public static colorWithAlpha(color: number, alpha: number): number {
    return (color & 0xffffff) | ((alpha & 0xff) << 24);
  }

  /**
   * turn an array of resource-colors (contains resource-id integers) into an
   * array list of actual color integers
   *
   * @param r
   * @param colors an integer array of resource id's of colors
   * @return
   */
  public static createColors(colors?: number[]): JArrayList<number> {
    let result: JArrayList<number> = new JArrayList<number>();
    if (colors) {
      for (let i = 0; i < colors.length; i++) {
        result.add(colors[i]);
      }
    }
    return result;
  }

  /**
   * from Color.rgb()
   * @param r
   * @param g
   * @param b
   */
  public static colorRgb(r: number, g: number, b: number): number {
    return 0xff000000 | (r << 16) | (g << 8) | b;
  }

  /**
   * from Color.argb()
   * @param alpha
   * @param red
   * @param green
   * @param blue
   */
  public static argb(alpha: number, red: number, green: number, blue: number): number {
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }

  /**
   * from Color red()
   * @param color
   */
  public static red(color: number): number {
    return (color >> 16) & 0xFF;
  }

  /**
   * from Color green()
   * @param color
   */
  public static green(color: number): number {
    return (color >> 8) & 0xFF;
  }

  /**
   * from Color blue()
   * @param color
   */
  public static blue(color: number): number {
    return color & 0xFF;
  }
}

export { ChartColor, ColorTemplate };

export default ColorTemplate