<?php

namespace App\Controller;

use App\Entity\User;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;

#[Route('/api/users')]
class UsersController extends AbstractController
{
    #[Route('', methods: ['GET'])]
    public function index(EntityManagerInterface $em): JsonResponse
    {
        $users = $em->getRepository(User::class)->findAll();

        $data = array_map(fn(User $u) => [
            'id' => $u->getId(),
            'name' => $u->getName(),
            'account_balance' => $u->getAccountBalance(),
        ], $users);

        return $this->json($data);
    }

    #[Route('/{id}', methods: ['GET'])]
    public function show(EntityManagerInterface $em, int $id): JsonResponse
    {
        $user = $em->getRepository(User::class)->find($id);

        if (!$user) {
            return $this->json(['error' => 'User not found'], 404);
        }

        return $this->json([
            'id' => $user->getId(),
            'name' => $user->getName(),
            'account_balance' => $user->getAccountBalance(),
        ]);
    }

    #[Route('', methods: ['POST'])]
    public function create(Request $request, EntityManagerInterface $em): JsonResponse
    {
        $data = json_decode($request->getContent(), true);

        if (!isset($data['name'], $data['account_balance'])) {
            return $this->json(['error' => 'Invalid data'], 400);
        }

        $user = new User();
        $user->setName($data['name']);
        $user->setAccountBalance((string) $data['account_balance']); // DECIMAL = string

        $em->persist($user);
        $em->flush();

        return $this->json([
            'id' => $user->getId(),
            'message' => 'User created'
        ], 201);
    }

    #[Route('/{id}', methods: ['PUT'])]
    public function update(int $id, Request $request, EntityManagerInterface $em): JsonResponse
    {
        $user = $em->getRepository(User::class)->find($id);

        if (!$user) {
            return $this->json(['error' => 'User not found'], 404);
        }

        $data = json_decode($request->getContent(), true);

        if (isset($data['name'])) {
            $user->setName($data['name']);
        }

        if (isset($data['account_balance'])) {
            $user->setAccountBalance((string) $data['account_balance']);
        }

        $em->flush();

        return $this->json(['message' => 'User updated']);
    }

    #[Route('/{id}', methods: ['DELETE'])]
    public function delete(int $id, EntityManagerInterface $em): JsonResponse
    {
        $user = $em->getRepository(User::class)->find($id);

        if (!$user) {
            return $this->json(['error' => 'User not found'], 404);
        }

        $em->remove($user);
        $em->flush();

        return $this->json(['message' => 'User deleted']);
    }
}
