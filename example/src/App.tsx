import type { PropsWithChildren } from 'react';
import {
  Alert,
  Button,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
  TouchableHighlight,
} from 'react-native';

import { AppYarnPackageView, SDKEnvironment } from '/Users/19046354/AppYarnPackage/src/index';

import { Colors } from 'react-native/Libraries/NewAppScreen';

import { setupSDK } from 'demo-project';
import { isReadyForSPay } from 'demo-project';
import { payWithBankInvoiceId } from 'demo-project';
import { payWithoutRefresh } from 'demo-project';
import { payWithPartPay } from 'demo-project';

type SectionProps = PropsWithChildren<{
  title: string;
}>;

function Section({ children, title }: SectionProps): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  return (
    <View style={styles.sectionContainer}>
      <Text
        style={[
          styles.sectionTitle,
          {
            color: isDarkMode ? Colors.white : Colors.black,
          },
        ]}>
        {title}
      </Text>
      {children}
    </View>
  );
}

export default function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  return (
    <SafeAreaView style={backgroundStyle}>
    <StatusBar
      barStyle={isDarkMode ? 'light-content' : 'dark-content'}
      backgroundColor={backgroundStyle.backgroundColor}
    />
    <ScrollView
      contentInsetAdjustmentBehavior="automatic"
      style={backgroundStyle}>
         <Section title="Setup methods:">
            <Button 
              title='Setup action'
              onPress={ appSetupSDK }
            />
            <Button 
              title='isReadyForSPay action'
              onPress={ appIsReadyForSPay }
            />
          </Section>
          <Section title="Auto pay method:">
            <Button 
              title='payWithBankInvoiceId action'
              onPress={ appPayWithBankInvoiceId }
              />
          </Section>
          <Section title="Pay without refresh token method:">
            <Button 
              title='payWithoutRefresh action'
              onPress={ appPayWithoutRefresh }
              />
          </Section>
          <Section title="Payment in installments with commission method:">
            <Button 
              title='payWithPartPay action'
              onPress={ appPayWithPartPay }
              />
          </Section>
          <Section title="Native button:">
          <TouchableHighlight onPress={onPressSPayButton} underlayColor="white">
            
             <AppYarnPackageView style={{
              height: 100,
              width: 112,
              paddingHorizontal: 16,
            }} color={''}          />
          </TouchableHighlight>
         </Section>
    </ScrollView>
    </SafeAreaView>
  );
}

function appSetupSDK() {
  var environment = SDKEnvironment.EnvironmentProd
  var testSetupParams = {
    'bnplPlan': true,
    'resultViewNeeded': true,
    'helpers': true,
    'needLogs': true,
    'sbp': false,
    'creditCard': true,
    'debitCard': false
  }
  setupSDK(
    testSetupParams,
    environment,
    (errorString: string) => {
      if(errorString) {
        Alert.alert(`Error found! ${errorString}`)
      }
      Alert.alert(`setup complited`)
    }
  )
}

function appIsReadyForSPay() {
  isReadyForSPay( 
    (isReady: boolean) => {
      Alert.alert(`is ready for spay: ${isReady}`)
  })
}

function appPayWithBankInvoiceId() {
  var requestParams = {
    'merchantLogin': 'mineev_sdk',
    'bankInvoiceId': 'b38892a1784d45db81a1a89134946cf1',
    'orderNumber': '412',
    'language': 'rus',
    'redirectUri': 'sdkdpxxaqglg://spay',
    'apiKey': 'AJpyllTD+0LKpCMDVZEB2ecAAAAAAAAADDLBcwrQjr5bOjn3yzYlFpCBk1nyQ9J46Ar3DrFBNyA92UJ7g/8zwuNose2pNnduv8JnjxD4h3HXdK8jTQB3pu7/HWqntPpBUCaA/8wqXK/gbgbJdWCU/7hzbtdYkxSD0u3qau9/4wM1p9WgkzNEPtPJE/gRKMk='
  }

  payWithBankInvoiceId(
    requestParams,
    (error: any, event: string) => {
      if(error) {
        Alert.alert(`Error found! ${error}`)
      }
      Alert.alert(`Pay with status: ${event}`)
    })
}

function appPayWithoutRefresh() {
  var requestParams = {
    'merchantLogin': 'Test shop',
    'bankInvoiceId': '12332323095123323230951233232322',
    'orderNumber': '412',
    'language': 'rus',
    'redirectUri': 'sberPayExampleapp://sberidauth',
    'apiKey': 'testApiKey'
  }

payWithoutRefresh(
    requestParams,
    (error: any, event: string) => {
      if(error) {
        Alert.alert(`Error found! ${error}`)
      }
      Alert.alert(`Pay with status: ${event}`)
    }
  )
}

function appPayWithPartPay() {
  var requestParams = {
    'merchantLogin': 'Test shop',
    'bankInvoiceId': '12332323095123323230951233232322',
    'orderNumber': '412',
    'language': 'rus',
    'redirectUri': 'sberPayExampleapp://sberidauth',
    'apiKey': 'testApiKey'
  }

payWithPartPay(
    requestParams,
    (error: any, event: string) => {
      if(error) {
        Alert.alert(`Error found! ${error}`)
      }
        Alert.alert(`Pay with status: ${event}`)
    }
  )
}

function onPressSPayButton() {
  Alert.alert('Button pressed')
}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});
