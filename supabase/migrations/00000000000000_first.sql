-- tables

CREATE SCHEMA IF NOT EXISTS public; -- the schema is named 'public' but it's not actually "public" per se. i just chose this name to reduce boilerplate in other parts of the code.

CREATE TABLE public.active_games (
  p1 TEXT NOT NULL,
  p1_end BIGINT NOT NULL,
  p1_points INTEGER NOT NULL,
  p1_rating INTEGER NOT NULL,
  p1_result FLOAT NOT NULL,
  p1_start BIGINT NOT NULL,
  p1_submissions TEXT[] NOT NULL,

  p2 TEXT NOT NULL,
  p2_end BIGINT NOT NULL,
  p2_points INTEGER NOT NULL,
  p2_rating INTEGER NOT NULL,
  p2_result FLOAT NOT NULL,
  p2_start BIGINT NOT NULL,
  p2_submissions TEXT[] NOT NULL,

  awaiting TEXT NOT NULL,
  game_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  problem_id TEXT NOT NULL,
  problem_rating INTEGER NOT NULL,
  problem_version INTEGER NOT NULL,
);

CREATE TABLE public.finished_games (
  LIKE public.active_games INCLUDING ALL,
  problem_creator UUID NOT NULL,
  p1_rating_change INTEGER NOT NULL,
  p2_rating_change INTEGER NOT NULL,
);

CREATE TABLE public.problems (
  creator UUID NOT NULL,
  disabled BOOLEAN NOT NULL,
  problem_id UUID NOT NULL PRIMARY KEY,
  random REAL NOT NULL CHECK (random >= 0 AND random <= 1),
  rating INTEGER NOT NULL,
  solve_time JSONB NOT NULL,
  versions JSONB NOT NULL
);

ALTER TABLE auth.users
ADD CONSTRAINT users_email_unique
UNIQUE (email);

CREATE TABLE public.users (
  creator BOOLEAN NOT NULL DEFAULT false,
  display_name TEXT NOT NULL DEFAULT 'New User',
  email TEXT REFERENCES auth.users(email)
    ON UPDATE CASCADE
    ON DELETE CASCADE
    NOT NULL,
  in_game TEXT NOT NULL,
  joined BIGINT NOT NULL DEFAULT (EXTRACT(EPOCH FROM NOW()) * 1000)::BIGINT,
  openai_key TEXT NOT NULL,
  rating INTEGER NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL PRIMARY KEY
);

-- file storage

INSERT INTO storage.buckets (id, name)
  VALUES 
    ('problems', 'problems'),

-- security

-- revoke all privileges from 'authenticated' and 'anon' roles on the 'public' and 'storage' schemas and their objects
REVOKE ALL ON SCHEMA public, storage FROM authenticated, anon;
REVOKE ALL ON ALL TABLES IN SCHEMA public, storage FROM authenticated, anon;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public, storage FROM authenticated, anon;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public, storage FROM authenticated, anon;

-- set default privileges to prevent 'authenticated' and 'anon' roles from gaining privileges on new objects in both schemas
ALTER DEFAULT PRIVILEGES IN SCHEMA public, storage REVOKE ALL ON TABLES FROM authenticated, anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public, storage REVOKE ALL ON SEQUENCES FROM authenticated, anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public, storage REVOKE ALL ON FUNCTIONS FROM authenticated, anon;

-- enable rls on all tables in 'public' schema
ALTER TABLE public.active_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.finished_games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.problems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- enable rls on storage.objects to ensure only server access
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

