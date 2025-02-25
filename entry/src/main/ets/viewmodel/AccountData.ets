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

export default class AccountData {
  id: number = -1;
  // 一般个人信息
  name: string = '用户';
  email: string = '';
  phoneNumber: string = '';
  address: string = '';

  // 余额存储
  wechatPayBalance: number = 0;
  alipayBalance: number = 0;
  applePayBalance: number = 0;
  googlePayBalance: number = 0;
  cardBalance: number = 0;

  // 密码
  password: string = ''; // 新增密码字段
}
