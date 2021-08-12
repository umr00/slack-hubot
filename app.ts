import { App } from '@slack/bolt';
import { addPlusPlusHandler } from './plusplus';
import { addSayHandler} from "./say";
import { addImageHandler } from "./image";

const app = new App({
    token: process.env.SLACK_BOT_TOKEN,
    signingSecret: process.env.SLACK_SIGNING_SECRET
});


function add_message(app: App) {
  app.message('hello', async ({ message, say}) => {
    if(message.subtype === undefined){
      await say({
        "text": `Hey there <@${message.user}>!`
      });
      await say(`${message.ts}`);
      await say(`${message.channel}`);
    }
  });
}

add_message(app);
addPlusPlusHandler(app);
addSayHandler(app);
addImageHandler(app);


app.event('app_mention', async ({event, say}) => {
  let pattern = /ping$/i;
  if(event.text.toLowerCase().match(pattern)){
    say("PONG");
  }
});

app.message(/^zoi (.*)/i, async ({context, say}) => {
  let [_, query] = context.matches;
  await say(`${query}はないぞい`);
});

(async () => {
    await app.start(Number(process.env.PORT) || 3000);

    console.log('⚡️ Bolt app is running!');
})();
