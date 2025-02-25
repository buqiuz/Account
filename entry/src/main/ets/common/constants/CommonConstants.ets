/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { relationalStore } from '@kit.ArkData';
import { AccountTable } from '../../viewmodel/ConstantsInterface';

export default class CommonConstants {
  /**
   * Rdb database config.
   */
  static readonly STORE_CONFIG: relationalStore.StoreConfig = {
    name: 'database.db',
    securityLevel: relationalStore.SecurityLevel.S1
  };
  /**
   * Account table config.
   */
  static readonly ACCOUNT_TABLE: AccountTable = {
    tableName: 'accountTable',
    sqlCreate: 'CREATE TABLE IF NOT EXISTS accountTable(' +
      'id INTEGER PRIMARY KEY AUTOINCREMENT, ' + // 账户ID
      'name TEXT, ' + // 姓名
      'email TEXT, ' + // 邮箱
      'phoneNumber TEXT, ' + // 电话号码
      'address TEXT, ' + // 地址
      'wechatPayBalance INTEGER, ' + // 微信余额
      'alipayBalance INTEGER, ' + // 支付宝余额
      'applePayBalance INTEGER, ' + // 苹果支付余额
      'googlePayBalance INTEGER, ' + // 谷歌支付余额
      'cardBalance INTEGER, ' + // 卡余额
      'password TEXT ' + // 密码
      ')',
    columns: [
      'id',
      'name',
      'email',
      'phoneNumber',
      'address',
      'wechatPayBalance',
      'alipayBalance',
      'applePayBalance',
      'googlePayBalance',
      'cardBalance',
      'password' // 新增的密码字段
    ]
  };



  /**
   * Account table config.
   */
  static readonly Bill_TABLE: AccountTable = {
    tableName: 'billTable',
    sqlCreate: `
    CREATE TABLE IF NOT EXISTS billTable(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      remark TEXT,
      title TEXT,
      time TEXT,
      amount INTEGER,
      method TEXT,
      accountType INTEGER
    )
  `,
    columns: ['id', 'remark', 'title', 'time', 'amount', 'method','accountType']
  };

  /**
   * Search text of Search component.
   */
  static readonly SEARCH_TEXT = $r('app.string.search');
  /**
   * toast text of prompt component.
   */
  static readonly TOAST_TEXT_1 = $r('app.string.TOAST_TEXT_1');
  static readonly TOAST_TEXT_2 = $r('app.string.TOAST_TEXT_2');
  /**
   * Component size.
   */
  static readonly FULL_WIDTH = '100%';
  static readonly FULL_HEIGHT = '100%';
  static readonly DIALOG_HEIGHT = '55%';
  static readonly TABS_HEIGHT = '35%';
  static readonly MINIMUM_SIZE = 0;
  static readonly FULL_SIZE = 1;
  static readonly PROMPT_BOTTOM = '70vp';
  /**
   * Component location.
   */
  static readonly EDIT_POSITION_X = '80%';
  static readonly EDIT_POSITION_Y = '60%';
  static readonly DELETE_POSITION_X = '50%';
  static readonly DELETE_POSITION_Y = '60%';
  /**
   * Log tag.
   */
  static readonly RDB_TAG = '[Debug.Rdb]';
  static readonly TABLE_TAG = '[Debug.AccountTable]';
  static readonly INDEX_TAG = '[Debug.Index]';
}