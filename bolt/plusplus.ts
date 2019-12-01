import {App, Context} from "@slack/bolt";
import {WebAPICallResult} from '@slack/web-api';
import Redis from "ioredis";
import Validator from 'validator';
import {parse} from "dotenv";
// original implementation is https://github.com/ajacksified/hubot-plusplus
// TODO only handle single line messages

interface UserInfoResult extends WebAPICallResult {
  user: {
    name: string;
  }
}

const scoreKeyword = process.env.HUBOT_PLUSPLUS_KEYWORD || "score";
const reasonsKeyword = process.env.HUBOT_PLUSPLUS_REASONS || "raisins";
const reasonConjunctions = process.env.HUBOT_PLUSPLUS_CONJUNCTIONS || "for|because|cause|cuz|as";
const REDIS_URL = process.env.REDIS_URL || "redis://127.0.0.1";

class ScoreKeeper {
  redis = new Redis(REDIS_URL);

  constructor() {

  }

  async incrementScore(user: string, fromUser: string, channel: string, reason: string, amount: number) {
    let score = this.redis.zincrby("score", amount, user).then((_) => {
      return this.redis.zscore("score", user)
        .then(s => {
          console.log(`saved ${s} to ${user}.`);
          return parseInt(s)
        });
    });

    let reasonScore: Promise<number> | undefined = undefined;
    if (reason) {
      let key = ["score", "reason", user].join(":");
      reasonScore = this.redis.zincrby(key, amount, user)
        .then((_) => {
          return this.redis.zscore(key, user).then(s => parseInt(s));
        });
    }
    this.saveScoreLog(user, fromUser, channel, reason);
    return Promise.all([score, reasonScore]);
  }

  eraseScore(user: string) {
    // FIXME current implementation just erase score.
    // TODO adding role or limitation for erase feature.
    let key = ["score", "reason", user].join(":");
    this.redis.del(key)
      .then(_ => console.log(`removed ${key}`));
    key = "score";
    this.redis.zrem(key, user)
      .then((_: any) => console.log(`removed ${user} of ${key}`));
  }

  last(channel: string): Promise<string | null>[] {
    let key = ["last", channel].join(":");
    let user = this.redis.hget(key, "user");
    let reason = this.redis.hget(key, "")

    return [user, reason];
  }

  saveScoreLog(user: string, fromUser: string, channel: string, reason: string): void {
    // FIXME current implementation just concatate `fromUser` and `user` with ':' ...
    // but user should not contain ':' because it's ID of Slack User.
    let key = ["log", fromUser, user].join(':');
    this.redis.lpush(key, new Date().getTime());

    key = ["last", channel].join(":");
    this.redis.hset(key, "user", user);
    if (reason) {
      this.redis.hset(key, "reason", reason);
    }
  }

  async getUserScore(user: string): Promise<number | undefined> {
    // FIXME use zscore
    let result: number | undefined = undefined;
    console.log("getting redis data...");
    let reply = await this.redis.zscore("score", user);
    if (reply) {
      result = Number(reply);
    }
    console.log("done getting redis data");

    return result;
  }

  async getUserReasonScore(user: string, reason: string): Promise<number | undefined> {
    // FIXME use zscore
    let result: number | undefined = undefined;
    console.log("getting redis data...");
    let key = [user, reason].join(":");
    let reply = await this.redis.get(key);
    if (reply && Validator.isInt(reply)) {
      result = Number(reply);
    }
    console.log("done getting redis data");

    return result;
  }

  async validate(fromUser: string, target: string, app: App, context: Context): Promise<boolean> {
    let reply = (app.client.users.info({
      token: context.botToken,
      user: fromUser
    })) as Promise<UserInfoResult>;

    let isSelfCount = reply.then((result) => {
      return target == result.user.name;
    });

    return !((await isSelfCount) || (await this.isSpam(fromUser, target)));
  }

  async isSpam(fromUser: string, target: string): Promise<boolean> {
    let key = ["log", fromUser, target].join(":");
    return this.redis.lindex(key, 0)
      .then((timestamp) => {
        if (timestamp == null) {
          return false;
        }

        console.assert(Validator.isInt(timestamp), `recorded data ${timestamp} in redis is not timestamp.`);
        let previousDate = new Date(Number(timestamp));
        return previousDate.setSeconds(previousDate.getSeconds() + 5) > new Date().getTime();
      });
  }

  async _topOrBottom(amount: number, top: boolean) {
    let cb = (result: any) => {
      let r = result as string[];
      let tops: { name: string, score: number }[] = [];
      for (let i = 0; i < r.length; i += 2) {
        tops.push({name: r[i], score: parseInt(r[i + 1])});
      }
      return tops
    };

    if (top) {
      return this.redis.zrevrange("score", 0, amount - 1, "WITHSCORES")
        .then(cb);
    } else {
      return this.redis.zrange("score", 0, amount - 1, "WITHSCORES")
        .then(cb);
    }
  }

  async top(amount: number) {
    return this._topOrBottom(amount, true);
  }

  async bottom(amount: number) {
    return this._topOrBottom(amount, false);
  }
}

const scoreKeeper = new ScoreKeeper();

/**
 * Main message handler for adding/subtracting score with/without reasons.
 * @param bolt app
 */
function addVoteHandler(app: App): void {
  const plusplusPattern = [
    "^", // from beginning of line
    `([\\s\\w'@.\\-:\\u3040-\\u30FF\\uFF01-\\uFF60\\u4E00-\\u9FA0]*)`, // the thing being upvoted, which is any number of words and spaces
    `\\s*`, // allow for spaces after the thing being upvoted (@user ++)
    `(\\+\\+|--|—)`, // the increment/decrement operator ++ or --// optional reason for the plusplus
    `(?:\\s+(?:${reasonConjunctions})\\s+(.+))?`, // optional reason for the plusplus
    "$", // end of line
  ].join('');

  app.message(new RegExp(plusplusPattern), async ({context, message, say}) => {
    let [_, name, operator, reason]: string[] = context.matches;
    name = name || "";

    let fromUser = message.user;
    let channel = message.channel;

    if (name) {
      // TODO need to understand this replacement.
      let replaceRegExp = name.charAt(0) == ':' ? /(^\s*@)|([,\s]*$)/g : /(^\s*@)|([,:\s]*$)/g;
      name = name.replace(replaceRegExp, '').trim().toLowerCase();
    }

    if (!(await scoreKeeper.validate(fromUser, name, app, context))) {
      // FIXME name may be ""
      console.log("validation failed. cannot add/sub score.");
      return
    }

    if (name == "") {
      let [lastUser, _] = scoreKeeper.last(channel);
      name = await lastUser || "";
      if (name == "") {
        say("cannot score to empty target.");
        console.debug("cannot score to empty target.");
        console.debug(`matched message: ${message}`);
        return;
      }
    }

    let amount = operator == "++" ? 1 : -1;
    let [score, reasonScore] = await scoreKeeper.incrementScore(name, fromUser, channel, reason, amount);

    let reasonStr = ".";
    if (reason && reasonScore !== undefined) {
      if (Math.abs(reasonScore) == 1 && Math.abs(score) == 1) {
        reasonStr = ` for ${reason}.`
      } else {
        let verb = reasonScore == 1 ? "is" : "are";
        reasonStr = `, ${reasonScore} of which ${verb} for ${reason}.`;
      }
    }

    let pointStr = score == 1 ? "point" : "points";
    say(`${name} has ${score} ${pointStr}${reasonStr}`);

    say(message.text || "");
    console.log([_, name, operator, reason].join(','))
  });
}

/**
 * message handler to show score ranking.
 * @param app
 */
function addTopBottomHandler(app: App): void {
  app.event('app_mention', async ({event, say}) => {
    const pattern = /(top|bottom) (\d+)/i;
    const match = event.text.match(pattern);

    if (match == null) {
      return;
    }

    let messages: string[] = [];
    let amount = parseInt(match[2]) || 10;

    let tbFunc = match[1] == "top" ? scoreKeeper.top.bind(scoreKeeper) : scoreKeeper.bottom.bind(scoreKeeper);
    let topOrBottoms = await tbFunc(amount);

    if (topOrBottoms.length == 0) {
      messages.push("There is no score.");
    }

    for (let i = 0; i < topOrBottoms.length; i++) {
      messages.push(`${i + 1}. ${topOrBottoms[i]["name"]} : ${topOrBottoms[i]["score"]}`);
    }

    say(messages.join("\n"));
  });
}

function addEraseHandler(app: App): void {
  app.event('app_mention', async ({event, say}) => {
    console.log(event.text + ";");
    const erasePattern = [
      // NOTE: slack trim whitespaces at the end of line.
      "(?:erase )", // from beginning of line
      "([\\s\\w'@.-:\\u3040-\\u30FF\\uFF01-\\uFF60\\u4E00-\\u9FA0]*)", // the thing being erased, which is any number of words and spaces
      // `(?:\\s+(?:${reasonConjunctions})\\s+(.+))?`, // optionally erase a reason from thing FIXME this regexp is meaningless.
      "$", // end of line
    ].join('');

    const match = event.text.match(erasePattern);
    if (match == null) {
      return;
    }
    console.log(match);
    await scoreKeeper.eraseScore(match[1]);
    say(`removed all scores of ${match[1]}`);
    //let name = match[1];

  });
}

function addShowScoreHandler(app: App): void {
  app.event('app_mention', async ({event, say}) => {
    // TODO getting and showing reasons score.
    const showScorePattern = `(?:${scoreKeyword}) (for\s)?(.*)`
    const match = event.text.match(showScorePattern);
    if (match == null || match[1] == "") {
      return;
    }

    let name = match[2];
    if (name) {
      // TODO need to understand this replacement.
      let replaceRegExp = name.charAt(0) == ':' ? /(^\s*@)|([,\s]*$)/g : /(^\s*@)|([,:\s]*$)/g;
      name = name.replace(replaceRegExp, '').trim().toLowerCase();
    }

    console.log("name is:" + name);

    let score = await scoreKeeper.getUserScore(name);
    if(score) {
      let pointStr = score == 1 ? "point" : "points";
      say(`${name} has ${score} ${pointStr}.`);
    } else {
      say(`${name} has no points.`);
    }

  })

}

export function addPlusPlusHandler(app: App): void {
  addVoteHandler(app);
  addTopBottomHandler(app);
  addEraseHandler(app);
  addShowScoreHandler(app);
}
