import {App, Context} from "@slack/bolt";
import axios from "axios";

const googleCseId = process.env.BOLT_GOOGLE_CSE_ID;
const googleApiKey = process.env.BOLT_GOOGLE_CSE_KEY;

export function addImageHandler(app: App): void {
  if (!googleCseId || !googleApiKey){
    console.error("Google CSE ID or GOOGLE CSE KEY is not defined.");
    return;
  }

  app.message(/^(image|img)( me)? (.*)/i, async({context, message, say}) => {
    let [all, command, me, query]: string[] = context.matches;

    let link = await getImageLink(query, false);
    if(link){
      say(link);
    } else {
      say(`Oops. I had trouble searching '${query}'. Try later.`);
    }
  });
}

async function getImageLink(query: string, animated: boolean) : Promise<string | null> {
  const url = 'https://www.googleapis.com/customsearch/v1';

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
    return item.link;
  } catch (error){
    return null;
  }
}
