import { App } from '@slack/bolt';
import { addPlusPlusHandler } from './plusplus';
import { addSayHandler} from "./say";

const app = new App({
    token: process.env.SLACK_BOT_TOKEN,
    signingSecret: process.env.SLACK_SIGNING_SECRET
});


function add_message(app: App) {
  app.message('hello', ({ message, say}) => {
    say({
      "text": `Hey there <@${message.user}>!`
    });
    say(`${message.ts}`);
    say(`${message.channel}`);
  });
}

add_message(app);
addPlusPlusHandler(app);
addSayHandler(app);


app.event('app_mention', ({event, say}) => {
  let pattern = /ping$/i;
  if(event.text.toLowerCase().match(pattern)){
    say("PONG");
  }
});

(async () => {
    await app.start(process.env.PORT || 3000);

    console.log('⚡️ Bolt app is running!');
})();
