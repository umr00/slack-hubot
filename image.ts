import {App, Context} from "@slack/bolt";
import axios, {AxiosError} from "axios";

export function addImageHandler(app: App): void {
  // robot.respond /(image|img)( me)? (.*)/i, (msg)
  app.message(/^(image|img)( me)? (.*)/i, async ({context, message, say}) => {
    let [_, cmd, me, query]: string[] = context.matches;

    const googleCseId = process.env.BOLT_GOOGLE_CSE_ID;
    const googleApiKey = process.env.BOLT_GOOGLE_CSE_KEY;

    // TODO add checking existence of CSE ID and API KEY

    let url = 'https://www.googleapis.com/customsearch/v1';

    try{
      const res = await axios.get(url, {
        params: {
          q: query,
          searchType: 'image',
          safe: 'high',
          fields: 'items(link)',
          cx: googleCseId,
          key: googleApiKey
        }
      });
      const item = res.data.items[Math.floor(Math.random() * res.data.items.length)];
      console.log(item.link);
      say(item.link);
    } catch (error){
      say(`Oops. I had trouble searching '${query}'. Try later.`);
    }
  });
}
