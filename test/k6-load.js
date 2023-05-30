import http from 'k6/http';
import {check, group, sleep, fail } from 'k6';
import encoding from 'k6/encoding';

const BASE_URL = 'https://5d9g6z4c31.execute-api.eu-west-1.amazonaws.com/serverless_gw_stage';
const DEBUG = true;

const start = Date.now();
const myPwd = 'ABCabc123!';

const ExecutionType = {
  load:   'load',
  smoke:  'smoke',
  stress: 'stress',
  soak:   'soak'
}

var Execution = 'load'; 
var ExecutionOptions_Scenarios;

switch(Execution){
    case ExecutionType.load:
        ExecutionOptions_Scenarios = {
            BackendFlow_scenario: {
                exec: 'BackendFlowTest',
                executor: 'ramping-vus',
                startVUs: 0,
                stages: [
                  { duration: '1m', target: 3 },
                  { duration: '2m', target: 4 },
                  { duration: '1m', target: 1 },
                ],
                gracefulRampDown: '10s',
            },
            AccountSetup_scenario: {
              exec: 'AccountSetup',
              executor: 'ramping-vus',
              startVUs: 0,
              stages: [
                { duration: '1m', target: 3 },
                { duration: '2m', target: 4 },
                { duration: '1m', target: 1 },
              ],
              gracefulRampDown: '10s',
        }
        }; 
        break; // end case ExecutionType.load    
  }


export let options ={
    scenarios: ExecutionOptions_Scenarios,
    thresholds: {
        http_req_failed: ['rate<0.05'],   
        'http_req_duration': ['p(90)<600','p(95)<700', 'p(99)<1500'],
    }
};

const htmlBasic = '<html><head><title>RANDOM</title></head><body><div id="contentArea"></div></body></html>'

function randomString(length) {
  const charset = 'abcdefghijklmnopqrstuvwxyz';
  let res = '';
  while (length--) res += charset[Math.random() * charset.length | 0];
  
  return res;
}

function randomNumberOfStrings(number) {
    const charset = 'abcdefghijklmnopqrstuvwxyz';
    let res = '';
    while (number--) res += randomString(5) + ' ';
    
    return res;
  }
  
function formatDate(date) {
  var hours = date.getHours();
  var minutes = date.getMinutes();
  var ampm = hours >= 12 ? 'pm' : 'am';
  hours = hours % 12;
  hours = hours ? hours : 12; // the hour '0' should be '12'
  minutes = minutes < 10 ? '0'+ minutes : minutes;
  var strTime = hours + ':' + minutes + ' ' + ampm;
  return (date.getMonth()+1) + "/" + date.getDate() + "/" + date.getFullYear() + "  " + strTime;
}

function DebugOrLog(textToLog){
  if (DEBUG){
      console.log(`${textToLog}`); 
  }
}



// Testing the backend with an end-to-end workflow (essentially the advanced API Flow sample at https://k6.io/docs/examples/advanced-api-flow/)
export function BackendFlowTest(authToken){
  const requestConfigWithTag = tag => ({
    headers: {
      Authorization: `Bearer ${authToken}`,
      'Content-Type': 'application/json'
    },
    tags: Object.assign({}, {
      name: 'WordscountK6'
    }, tag)
  });
  group('Count Words', () => {
    let URL = `${BASE_URL}/countWords`;
    let htmlPage=htmlBasic.replace('RANDOM', randomNumberOfStrings(Math.random() * 2000 | 0));

    const countRes = http.post(URL, encoding.b64encode(htmlPage),  requestConfigWithTag({ name: 'randomHtml' }));

    const isSuccessfulCount = check(null, {
      'Words were counted correctly': () => countRes.status === 200,
    });

    if (!isSuccessfulCount) {
        DebugOrLog(`Words were not counted properly`);
      return;
    }

  });

}

export function AccountSetup() {

   // register a new user and authenticate via a Bearer token.
  let user = `${randomString(10)}`;
  let authToken;

  group('Signup user', () => {
    let res = http.post(`${BASE_URL}/signup`, JSON.stringify({
      email: user + '@example.com',
      username: user,
      password: myPwd,
      name: user,
    }), {headers: {
        'Content-Type': 'application/json'
    }}); 

    const isSuccessfulRequest = check(res, { 
        'created user': (r) => r.status === 200
    }); 
  });

  group('Signin user', () => {
      
    let loginRes = http.post(`${BASE_URL}/signin`, JSON.stringify({
      username: user,
      password: myPwd,
    }),{
      headers: {
      'Content-Type': 'application/json'
    }});
    
    const isSuccessfulLogin = check(loginRes, { 
      'login user': (r) => r.status === 200 
    }); 
    
    authToken = loginRes.json('id_token');
    let logInSuccessful = check(authToken, { 
        'logged in successfully': () => authToken !== '', 
    });

  });  
 
}
// setup configuration
export function setup() {
  DebugOrLog(`== SETUP BEGIN ===========================================================`)
  // log the date & time start of the test
  DebugOrLog(`Start of test: ${formatDate(new Date())}`)

  // log the test type
  DebugOrLog(`Test executed: ${Execution}`)

   // register a new user and authenticate via a Bearer token.
  let user = `${randomString(10)}`;
  let res = http.post(`${BASE_URL}/signup`, JSON.stringify({
    email: user + '@example.com',
    username: user,
    password: myPwd,
    name: user,
}), {headers: {
      'Content-Type': 'application/json'
  }}); 

  const isSuccessfulRequest = check(res, { 
      'created user': (r) => r.status === 200 
  }); //200 = created

  if (isSuccessfulRequest){
      DebugOrLog(`The user ${user} was created successfully!`);
  }
  else {
      DebugOrLog(`There was a problem creating the user ${user}. It might be existing, so please modify it on the executor bat file`);
      DebugOrLog(`The http status is ${res.status}`);        
      DebugOrLog(`The http error is ${res.error}`);        
  }

  let loginRes = http.post(`${BASE_URL}/signin`, JSON.stringify({
    username: user,
    password: myPwd,
  }),{
    headers: {
    'Content-Type': 'application/json'
  }});
  
  const isSuccessfulLogin = check(loginRes, { 
    'login user': (r) => r.status === 200 
  }); 
  
  if (isSuccessfulLogin){
    DebugOrLog(`The user ${user} was logged in successfully!`);
}
else {
    DebugOrLog(`There was a problem logging in the user ${user}. `);
    DebugOrLog(`The http status is ${res.status}`);        
    DebugOrLog(`The http error is ${res.error}`);        
}

  let authToken = loginRes.json('id_token');
  let logInSuccessful = check(authToken, { 
      'logged in successfully': () => authToken !== '', 
  });

  if (logInSuccessful){
      DebugOrLog(`Logged in successfully with the token.`); 
  }

   DebugOrLog(`== SETUP END ===========================================================`)
 
  return authToken; // this will be passed as parameter to all the exported functions
}