import {App, Context} from "@slack/bolt";
import axios from "axios";

const googleCseId = process.env.BOLT_GOOGLE_CSE_ID;
const googleApiKey = process.env.BOLT_GOOGLE_CSE_KEY;

export function addImageHandler(app: App): void {
  if (!googleCseId || !googleApiKey){
    console.error("Google CSE ID or GOOGLE CSE KEY is not defined.");
    return;
  }

  app.message(/^(animate|image|img)( me)? (.*)/i, async({context, message, say}) => {
    let [all, command, me, query]: string[] = context.matches;

    let link = await getImageLink(query, command == 'animate');
    if(link){
      await say(link);
    } else {
      await say(`Oops. I had trouble searching '${query}'. Try later.`);
    }
  });

  app.message(/はらへ/i, async({context, message, say}) => {
    let foods: Array<string> = [
      "ラーメン",
      "焼肉",
      "餃子",
      "唐揚げ",
      "焼き鳥",
      "串カツ",
      "粉もの",
      "スイーツ"
    ];
    let query = foods[Math.floor(Math.random() * foods.length)] 
    let link = await getImageLink(query, false);
    if(link){
      await say(link);
    } else {
      await say(`Oops. I had trouble searching '${query}'. Try later.`);
    }
  });
}

async function getImageLink(query: string, animated: boolean) : Promise<string | null> {
  const url = 'https://www.googleapis.com/customsearch/v1';

  try{
    let p: any = {
      q: query,
      searchType: 'image',
      safe: 'high',
      fields: 'items(link)',
      cx: googleCseId,
      key: googleApiKey
    };

    if(animated) {
      p.fileType = 'gif';
      p.hq = 'animated';
      p.tbs = 'itp:animated';
    }

    const res = await axios.get(url, {
      params: p
    });
    const item = res.data.items[Math.floor(Math.random() * res.data.items.length)];
    return item.link;
  } catch (error){
    return null;
  }
}
