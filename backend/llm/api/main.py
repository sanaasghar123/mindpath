import json
import os
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field


class MoodInputs(BaseModel):
  moodText: str = Field(..., min_length=1)
  moodScore: float = Field(..., ge=0, le=10)
  moodLabel: str = Field(..., min_length=1)


class MoodHistoryItem(BaseModel):
  timestamp: Optional[str] = None
  moodLabel: Optional[str] = None
  moodText: Optional[str] = None
  moodScore: Optional[float] = Field(default=None, ge=0, le=10)
  sentiment: Optional[str] = None
  emotion: Optional[str] = None
  insight: Optional[str] = None


class MoodAnalyzeRequest(BaseModel):
  prompt: Optional[str] = None
  inputs: MoodInputs
  history: Optional[List[MoodHistoryItem]] = None
  languageInstruction: Optional[str] = None


class MoodAnalyzeResponse(BaseModel):
  sentiment: str
  emotion: str
  insight: str
  progression: str


def _build_prompt(
  inputs: MoodInputs,
  history: Optional[List[MoodHistoryItem]],
  language_instruction: Optional[str],
) -> str:
  if history:
    lines: List[str] = []
    for item in history[:8]:
      ts = (item.timestamp or "").strip()
      score = "" if item.moodScore is None else str(item.moodScore)
      sentiment = (item.sentiment or "").strip()
      emotion = (item.emotion or "").strip()
      insight = (item.insight or "").strip()
      text = (item.moodText or "").strip()
      short_text = (text[:140] + "…") if len(text) > 140 else text
      lines.append(
        f'- {ts} | score: {score} | {sentiment} | {emotion} | insight: "{insight}" | text: "{short_text}"'
      )
    history_text = "\n".join(lines)
  else:
    history_text = "No previous assessments."

  prompt = f'''
You are a mental wellness assistant. Analyze the user's mood check-in and produce a concise JSON object.

User input:
- moodLabel: "{inputs.moodLabel}"
- moodScore (0-10): {inputs.moodScore}
- moodText: "{inputs.moodText}"

Previous context (most recent first):
{history_text}

Return ONLY valid JSON with exactly these keys:
{{
  "sentiment": "positive|neutral|negative",
  "emotion": "stress|anxiety|calm|joy|sadness|anger|fatigue|overwhelm|other",
  "insight": "A short, compassionate, personalized insight (1-2 sentences).",
  "progression": "A short progression compared to the previous assessment (e.g., improving|stable|worsening + one short phrase)."
}}

Rules:
- Keep insight supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
'''.strip()
  if language_instruction and language_instruction.strip():
    prompt = f"{prompt}\n\n{language_instruction.strip()}"
  return prompt

class JournalEntryPayload(BaseModel):
  timestamp: Optional[str] = None
  moodLabel: Optional[str] = None
  moodScore: Optional[float] = Field(default=None, ge=0, le=10)
  moodText: str = Field(..., min_length=1)


class JournalInsightRequest(BaseModel):
  entry: JournalEntryPayload
  history: Optional[List[MoodHistoryItem]] = None
  languageInstruction: Optional[str] = None


class JournalInsightResponse(BaseModel):
  reflection: str
  suggestion: str
  nextStep: str


class JournalAnalyzeRequest(BaseModel):
  text: str = Field(..., min_length=1)
  history: Optional[List[Dict[str, Any]]] = None
  languageInstruction: Optional[str] = None


class JournalAnalyzeResponse(BaseModel):
  sentiment: str
  emotion: str
  insight: str
  tags: List[str]


def _build_journal_analyze_prompt(
  text: str,
  history: Optional[List[Dict[str, Any]]],
  language_instruction: Optional[str],
) -> str:
  history_text = "No previous entries."
  if history:
    lines: List[str] = []
    for item in history[:8]:
      ts = str(item.get("createdAt", "")).strip()
      emotion = str(item.get("emotion", "")).strip()
      sentiment = str(item.get("sentiment", "")).strip()
      insight = str(item.get("insight", "")).strip()
      tags = item.get("tags", [])
      tag_text = ", ".join([str(t) for t in tags[:6]]) if isinstance(tags, list) else ""
      lines.append(f'- {ts} | {sentiment} | {emotion} | tags: [{tag_text}] | insight: "{insight}"')
    history_text = "\n".join(lines)

  prompt = f'''
Analyze the following journal entry.

Journal entry:
"""{text}"""

Previous patterns (optional context):
{history_text}

Return ONLY valid JSON:
{{
  "sentiment": "positive|neutral|negative",
  "emotion": "calm|stress|anxiety|joy",
  "insight": "short supportive reflection",
  "tags": ["overthinking", "growth"]
}}

Rules:
- Be supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
'''.strip()
  if language_instruction and language_instruction.strip():
    prompt = f"{prompt}\n\n{language_instruction.strip()}"
  return prompt


def _fallback_journal_analyze(text: str) -> Dict[str, Any]:
  lowered = text.lower()
  if any(k in lowered for k in ["panic", "anxious", "anxiety", "worry", "worried"]):
    emotion = "anxiety"
    sentiment = "negative"
    tags = ["anxiety", "overthinking"]
  elif any(k in lowered for k in ["stress", "overwhelmed", "pressure", "burnout"]):
    emotion = "stress"
    sentiment = "negative"
    tags = ["stress", "overwhelm"]
  elif any(k in lowered for k in ["grateful", "happy", "proud", "excited", "joy"]):
    emotion = "joy"
    sentiment = "positive"
    tags = ["gratitude", "growth"]
  else:
    emotion = "calm"
    sentiment = "neutral"
    tags = ["reflection"]

  insight = "Thank you for sharing this. Try to name one feeling you notice and one small support you can give yourself today."
  return {"sentiment": sentiment, "emotion": emotion, "insight": insight, "tags": tags}

class JournalDeepInsightRequest(BaseModel):
  entry: Dict[str, Any]
  history: Optional[List[Dict[str, Any]]] = None
  languageInstruction: Optional[str] = None


class JournalDeepInsightResponse(BaseModel):
  reflection: str
  suggestion: str
  nextStep: str


def _build_journal_deep_insight_prompt(
  entry: Dict[str, Any],
  history: Optional[List[Dict[str, Any]]],
  language_instruction: Optional[str],
) -> str:
  text = str(entry.get("text", "")).strip()
  emotion = str(entry.get("emotion", "")).strip()
  sentiment = str(entry.get("sentiment", "")).strip()
  tags = entry.get("tags", [])
  tag_text = ", ".join([str(t) for t in tags[:8]]) if isinstance(tags, list) else ""
  created_at = str(entry.get("createdAt", "")).strip()

  history_text = "No previous entries."
  if history:
    lines: List[str] = []
    for item in history[:10]:
      ts = str(item.get("createdAt", "")).strip()
      e = str(item.get("emotion", "")).strip()
      s = str(item.get("sentiment", "")).strip()
      i = str(item.get("insight", "")).strip()
      tgs = item.get("tags", [])
      ttxt = ", ".join([str(t) for t in tgs[:6]]) if isinstance(tgs, list) else ""
      lines.append(f'- {ts} | {s} | {e} | tags: [{ttxt}] | insight: "{i}"')
    history_text = "\n".join(lines)

  prompt = f'''
You are a mental wellness assistant. Provide AI-based insights for a single journal entry while considering the user's previous journaling patterns.

Journal entry (focus on this entry):
- createdAt: "{created_at}"
- sentiment: "{sentiment}"
- emotion: "{emotion}"
- tags: [{tag_text}]
- text: "{text}"

Previous journal context (most recent first):
{history_text}

Return ONLY valid JSON with exactly these keys:
{{
  "reflection": "A personalized reflection referencing this journal entry and the user's trend (2-4 sentences).",
  "suggestion": "One personalized suggestion based on the emotional trend (1-2 sentences).",
  "nextStep": "One concrete next step (e.g., breathing tip, mindful exercise) written as a short instruction."
}}

Rules:
- Be supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
'''.strip()
  if language_instruction and language_instruction.strip():
    prompt = f"{prompt}\n\n{language_instruction.strip()}"
  return prompt


def _fallback_journal_deep_insight(
  entry: Dict[str, Any],
  history: Optional[List[Dict[str, Any]]],
) -> Dict[str, str]:
  reflection = "Thank you for sharing this. Your journal shows self-awareness, and that’s a meaningful step toward steadier days."
  emotion = str(entry.get("emotion", "")).strip().lower()
  if emotion == "anxiety":
    suggestion = "Try to separate facts from predictions: write one thing you know is true, and one fear that is only a possibility."
    next_step = "Do a 60-second grounding: name 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste."
  elif emotion == "stress":
    suggestion = "Choose one task you can reduce or delay, and give yourself permission to do it imperfectly."
    next_step = "Set a 10-minute timer and do the smallest next action, then stop and reassess."
  elif emotion == "joy":
    suggestion = "Notice what helped you feel this way and plan one small repeatable version for tomorrow."
    next_step = "Write one sentence of gratitude and share it with yourself or someone you trust."
  else:
    suggestion = "Pick one feeling word that fits best and let it be enough for today—no need to solve everything at once."
    next_step = "Try box breathing: inhale 4, hold 4, exhale 4, hold 4. Repeat 4 cycles."

  return {"reflection": reflection, "suggestion": suggestion, "nextStep": next_step}

def _build_journal_insight_prompt(
  entry: JournalEntryPayload,
  history: Optional[List[MoodHistoryItem]],
  language_instruction: Optional[str],
) -> str:
  if history:
    lines: List[str] = []
    for item in history[:12]:
      ts = (item.timestamp or "").strip()
      score = "" if item.moodScore is None else str(item.moodScore)
      label = (item.moodLabel or "").strip()
      sentiment = (item.sentiment or "").strip()
      emotion = (item.emotion or "").strip()
      insight = (item.insight or "").strip()
      text = (item.moodText or "").strip()
      short_text = (text[:140] + "…") if len(text) > 140 else text
      lines.append(
        f'- {ts} | label: {label} | score: {score} | {sentiment} | {emotion} | insight: "{insight}" | text: "{short_text}"'
      )
    history_text = "\n".join(lines)
  else:
    history_text = "No previous assessments."

  prompt = f'''
You are a mental wellness assistant. Provide AI-based insights for a single journal entry while considering the user's prior mood patterns.

Journal entry (focus on this entry):
- timestamp: "{(entry.timestamp or "").strip()}"
- moodLabel: "{(entry.moodLabel or "").strip()}"
- moodScore (0-10): {"" if entry.moodScore is None else entry.moodScore}
- moodText: "{entry.moodText}"

Previous mood context (most recent first):
{history_text}

Return ONLY valid JSON with exactly these keys:
{{
  "reflection": "A personalized reflection referencing this journal entry and the user's trend (2-4 sentences).",
  "suggestion": "One personalized suggestion based on the emotional trend (1-2 sentences).",
  "nextStep": "One concrete next step (e.g., breathing tip, mindful exercise) written as a short instruction."
}}

Rules:
- Be supportive and non-clinical.
- Do not mention you are an AI.
- No extra keys, no markdown.
'''.strip()
  if language_instruction and language_instruction.strip():
    prompt = f"{prompt}\n\n{language_instruction.strip()}"
  return prompt


def _fallback(
  inputs: MoodInputs,
  history: Optional[List[MoodHistoryItem]],
) -> Dict[str, str]:
  score = inputs.moodScore
  if score >= 7:
    sentiment = "positive"
  elif score >= 4:
    sentiment = "neutral"
  else:
    sentiment = "negative"

  label = inputs.moodLabel.lower()
  if "tense" in label or "stress" in label:
    emotion = "stress"
  elif "down" in label or "sad" in label:
    emotion = "sadness"
  elif "pensive" in label:
    emotion = "overwhelm"
  elif "grateful" in label:
    emotion = "joy"
  elif "neutral" in label:
    emotion = "calm"
  else:
    emotion = "other"

  progression = "stable"
  if history and history[0].moodScore is not None:
    delta = inputs.moodScore - float(history[0].moodScore)
    if delta >= 1:
      progression = "improving"
    elif delta <= -1:
      progression = "worsening"

  insight = "Thank you for checking in. Take one slow breath and choose one small, kind next step for yourself today."
  return {
    "sentiment": sentiment,
    "emotion": emotion,
    "insight": insight,
    "progression": progression,
  }

def _fallback_journal_insight(
  entry: JournalEntryPayload,
  history: Optional[List[MoodHistoryItem]],
) -> Dict[str, str]:
  reflection = "Thank you for sharing this. Your words show you’re paying attention to what’s happening inside, which is a strong first step."
  if history and history[0].moodScore is not None and entry.moodScore is not None:
    delta = float(entry.moodScore) - float(history[0].moodScore)
    if delta >= 1:
      reflection = "This entry feels like a step forward compared to your most recent check-in. Notice what supported that shift and try to protect a small piece of it tomorrow."
    elif delta <= -1:
      reflection = "This entry suggests things feel heavier than your most recent check-in. That’s understandable—try to be gentle with yourself and focus on one small stabilizing action."

  suggestion = "Pick one theme from your entry and name it in a single word. That can help your mind feel more organized and less overwhelmed."
  next_step = "Try 4–7–8 breathing: inhale 4 seconds, hold 7 seconds, exhale 8 seconds. Repeat 3 times."
  return {"reflection": reflection, "suggestion": suggestion, "nextStep": next_step}


def _parse_json_from_text(text: str) -> Dict[str, Any]:
  text = text.strip()
  if text.startswith("```"):
    text = text.strip("`").strip()
  start = text.find("{")
  end = text.rfind("}")
  if start == -1 or end == -1 or end <= start:
    raise ValueError("No JSON object found")
  return json.loads(text[start : end + 1])


def _call_llama_cpp(prompt: str) -> Dict[str, str]:
  base_url = os.getenv("LLAMA_CPP_BASE_URL", "http://127.0.0.1:8080")
  model = os.getenv("LLAMA_CPP_MODEL")
  temperature = float(os.getenv("LLAMA_CPP_TEMPERATURE", "0.2"))
  max_tokens = int(os.getenv("LLAMA_CPP_MAX_TOKENS", "250"))
  timeout_s = float(os.getenv("LLAMA_CPP_TIMEOUT_S", "30"))

  payload: Dict[str, Any] = {
    "messages": [
      {"role": "system", "content": "You are a helpful assistant."},
      {"role": "user", "content": prompt},
    ],
    "temperature": temperature,
    "max_tokens": max_tokens,
  }
  if model:
    payload["model"] = model

  r = requests.post(
    f"{base_url}/v1/chat/completions",
    json=payload,
    timeout=timeout_s,
  )
  r.raise_for_status()
  data = r.json()
  content = (
    (data.get("choices") or [{}])[0]
    .get("message", {})
    .get("content", "")
  )
  parsed = _parse_json_from_text(content)
  sentiment = str(parsed.get("sentiment", "")).strip()
  emotion = str(parsed.get("emotion", "")).strip()
  insight = str(parsed.get("insight", "")).strip()
  progression = str(parsed.get("progression", "")).strip()
  if not sentiment or not emotion or not insight or not progression:
    raise ValueError("Missing fields in model output")
  return {
    "sentiment": sentiment,
    "emotion": emotion,
    "insight": insight,
    "progression": progression,
  }


app = FastAPI(title="MindPath LLM API")


@app.get("/health")
def health() -> Dict[str, str]:
  return {"status": "ok", "ts": datetime.now(timezone.utc).isoformat()}


@app.post("/mood/analyze", response_model=MoodAnalyzeResponse)
def mood_analyze(req: MoodAnalyzeRequest) -> Dict[str, str]:
  if req.prompt:
    prompt = req.prompt.strip()
    if req.languageInstruction and req.languageInstruction.strip():
      prompt = f"{prompt}\n\n{req.languageInstruction.strip()}"
  else:
    prompt = _build_prompt(req.inputs, req.history, req.languageInstruction)
  try:
    return _call_llama_cpp(prompt)
  except requests.RequestException as e:
    return _fallback(req.inputs, req.history)
  except Exception:
    return _fallback(req.inputs, req.history)


@app.post("/journal/insight", response_model=JournalInsightResponse)
def journal_insight(req: JournalInsightRequest) -> Dict[str, str]:
  prompt = _build_journal_insight_prompt(
    req.entry,
    req.history,
    req.languageInstruction,
  )
  try:
    base_url = os.getenv("LLAMA_CPP_BASE_URL", "http://127.0.0.1:8080")
    model = os.getenv("LLAMA_CPP_MODEL")
    temperature = float(os.getenv("LLAMA_CPP_TEMPERATURE", "0.2"))
    max_tokens = int(os.getenv("LLAMA_CPP_MAX_TOKENS", "350"))
    timeout_s = float(os.getenv("LLAMA_CPP_TIMEOUT_S", "30"))

    payload: Dict[str, Any] = {
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt},
      ],
      "temperature": temperature,
      "max_tokens": max_tokens,
    }
    if model:
      payload["model"] = model

    r = requests.post(
      f"{base_url}/v1/chat/completions",
      json=payload,
      timeout=timeout_s,
    )
    r.raise_for_status()
    data = r.json()
    content = (
      (data.get("choices") or [{}])[0]
      .get("message", {})
      .get("content", "")
    )
    parsed = _parse_json_from_text(content)
    reflection = str(parsed.get("reflection", "")).strip()
    suggestion = str(parsed.get("suggestion", "")).strip()
    next_step = str(parsed.get("nextStep", "")).strip()
    if not reflection or not suggestion or not next_step:
      raise ValueError("Missing fields in model output")
    return {"reflection": reflection, "suggestion": suggestion, "nextStep": next_step}
  except requests.RequestException:
    return _fallback_journal_insight(req.entry, req.history)
  except Exception:
    return _fallback_journal_insight(req.entry, req.history)


@app.post("/journal/analyze", response_model=JournalAnalyzeResponse)
def journal_analyze(req: JournalAnalyzeRequest) -> Dict[str, Any]:
  prompt = _build_journal_analyze_prompt(req.text, req.history, req.languageInstruction)
  try:
    base_url = os.getenv("LLAMA_CPP_BASE_URL", "http://127.0.0.1:8080")
    model = os.getenv("LLAMA_CPP_MODEL")
    temperature = float(os.getenv("LLAMA_CPP_TEMPERATURE", "0.2"))
    max_tokens = int(os.getenv("LLAMA_CPP_MAX_TOKENS", "350"))
    timeout_s = float(os.getenv("LLAMA_CPP_TIMEOUT_S", "30"))

    payload: Dict[str, Any] = {
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt},
      ],
      "temperature": temperature,
      "max_tokens": max_tokens,
    }
    if model:
      payload["model"] = model

    r = requests.post(
      f"{base_url}/v1/chat/completions",
      json=payload,
      timeout=timeout_s,
    )
    r.raise_for_status()
    data = r.json()
    content = (
      (data.get("choices") or [{}])[0]
      .get("message", {})
      .get("content", "")
    )
    parsed = _parse_json_from_text(content)
    sentiment = str(parsed.get("sentiment", "")).strip()
    emotion = str(parsed.get("emotion", "")).strip()
    insight = str(parsed.get("insight", "")).strip()
    raw_tags = parsed.get("tags", [])
    tags: List[str] = (
      [str(t).strip() for t in raw_tags if str(t).strip()] if isinstance(raw_tags, list) else []
    )
    if not sentiment or not emotion or not insight:
      raise ValueError("Missing fields in model output")
    if not tags:
      tags = ["reflection"]
    return {"sentiment": sentiment, "emotion": emotion, "insight": insight, "tags": tags}
  except requests.RequestException:
    return _fallback_journal_analyze(req.text)
  except Exception:
    return _fallback_journal_analyze(req.text)


@app.post("/journal/deep_insight", response_model=JournalDeepInsightResponse)
def journal_deep_insight(req: JournalDeepInsightRequest) -> Dict[str, Any]:
  prompt = _build_journal_deep_insight_prompt(
    req.entry,
    req.history,
    req.languageInstruction,
  )
  try:
    base_url = os.getenv("LLAMA_CPP_BASE_URL", "http://127.0.0.1:8080")
    model = os.getenv("LLAMA_CPP_MODEL")
    temperature = float(os.getenv("LLAMA_CPP_TEMPERATURE", "0.2"))
    max_tokens = int(os.getenv("LLAMA_CPP_MAX_TOKENS", "450"))
    timeout_s = float(os.getenv("LLAMA_CPP_TIMEOUT_S", "30"))

    payload: Dict[str, Any] = {
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": prompt},
      ],
      "temperature": temperature,
      "max_tokens": max_tokens,
    }
    if model:
      payload["model"] = model

    r = requests.post(
      f"{base_url}/v1/chat/completions",
      json=payload,
      timeout=timeout_s,
    )
    r.raise_for_status()
    data = r.json()
    content = (
      (data.get("choices") or [{}])[0]
      .get("message", {})
      .get("content", "")
    )
    parsed = _parse_json_from_text(content)
    reflection = str(parsed.get("reflection", "")).strip()
    suggestion = str(parsed.get("suggestion", "")).strip()
    next_step = str(parsed.get("nextStep", "")).strip()
    if not reflection or not suggestion or not next_step:
      raise ValueError("Missing fields in model output")
    return {"reflection": reflection, "suggestion": suggestion, "nextStep": next_step}
  except requests.RequestException:
    return _fallback_journal_deep_insight(req.entry, req.history)
  except Exception:
    return _fallback_journal_deep_insight(req.entry, req.history)
