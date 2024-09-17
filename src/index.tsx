import {
  requireNativeComponent,
  UIManager,
  NativeModules,
  Platform,
  type ViewStyle,
} from 'react-native';

const LINKING_ERROR =
  `The package 'demo-project' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

  type AppYarnPackageViewProps = {
    color: string;
    style: ViewStyle;
  };
  
  const ComponentName = 'AppYarnPackageView';
    
  export const AppYarnPackageView =
    UIManager.getViewManagerConfig(ComponentName) != null
        ? requireNativeComponent<AppYarnPackageViewProps>(ComponentName)
        : () => {
            throw new Error(LINKING_ERROR);
          };

const AppYarnPackage = NativeModules.AppYarnPackage
  ? NativeModules.AppYarnPackage
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

    export function setupSDK(params: {
      bnplPlan: boolean,
      resultViewNeeded: boolean,
      helpers: boolean,
      needLogs: boolean,
      sbp: boolean,
      creditCard: boolean,
      debitCard: boolean
    },
    fn: (errorString: string) => void) {
  AppYarnPackage.setupSDK(params, (errorString: string) => fn(errorString))
}

export function isReadyForSPay(fn: (isReady: boolean) => void) {
  AppYarnPackage.isReadyForSPay((event: boolean) => fn(event));
}

export function payWithBankInvoiceId(requestParams: {
                  merchantLogin: string, 
                  bankInvoiceId: string,
                  orderNumber: string,
                  language: string,
                  redirectUri: string
                  apiKey: string
                }, 
                fn: (error: any, event: string) => void) {                    
  AppYarnPackage.payWithBankInvoiceId(requestParams, (error: any, event: string) => fn(error, event))
}

export function payWithoutRefresh(requestParams: {
                merchantLogin: string, 
                bankInvoiceId: string,
                orderNumber: string,
                language: string,
                redirectUri: string
                apiKey: string
              }, 
              fn: (error: any, event: string) => void) {
  AppYarnPackage.payWithoutRefresh(requestParams, (error: any, event: string) => fn(error, event))
}

export function payWithPartPay(requestParams: {
            merchantLogin: string, 
            bankInvoiceId: string,
            orderNumber: string,
            language: string,
            redirectUri: string
            apiKey: string
          }, 
          fn: (error: any, event: string) => void) {
  AppYarnPackage.payWithPartPay(requestParams,(error: any, event: string) => fn(error, event))
}
