import {App, Context} from "@slack/bolt";

export function addSayHandler(app: App): void {
  app.message(/^say\s+(.*)$/, async ({context, message, say}) => {
    if (message.channel_type != "im") {
      return;
    }
    let [_, msg]: string[] = context.matches;
    await app.client.chat.postMessage( {
      token: context.botToken,
      channel: "#general",
      text: msg
    });
    say("「" + msg + "」を #general で発言しました！");
  });
}
